package vexriscv.VexRiscvForSim

import spinal.core._
import spinal.lib._
import vexriscv.ip.{DataCacheConfig, InstructionCacheConfig}
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.amba4.axi._
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.io.{InOutWrapper, TriStateArray}
import spinal.lib.misc.{InterruptCtrl, Prescaler, Timer}
import spinal.lib.soc.pinsec.{PinsecTimerCtrl, PinsecTimerCtrlExternal}
import vexriscv.plugin._
import vexriscv.{VexRiscv, VexRiscvConfig, plugin}
import spinal.lib.com.spi.ddr._
import spinal.lib.bus.simple._
import scala.collection.mutable.ArrayBuffer


case class RiscvConfig(
                       coreFrequency : HertzNumber,
                       cpuPlugins              : ArrayBuffer[Plugin[VexRiscv]]){
}

object RiscvConfig{
   def default : RiscvConfig = default(false)
   def default(bigEndian : Boolean = false) =  RiscvConfig(
   coreFrequency         = 166 MHz,
   cpuPlugins = ArrayBuffer(
      new IBusCachedPlugin(
          resetVector = 0x00004000l,
          prediction = STATIC,
          relaxedPcCalculation = true,
          config = InstructionCacheConfig(
            cacheSize = 4096*2,
            bytePerLine =32,
            wayCount = 2,
            addressWidth = 32,
            cpuDataWidth = 32,
            memDataWidth = 32,
            catchIllegalAccess = true,
            catchAccessFault = true,
            asyncTagMemory = false,
            twoCycleRam = true,
            twoCycleCache = true
          )
      ),
      new DBusCachedPlugin(
          config = new DataCacheConfig(
            cacheSize         = 4096*2,
            bytePerLine       = 32,
            wayCount          = 2,
            addressWidth      = 32,
            cpuDataWidth      = 32,
            memDataWidth      = 32,
            catchAccessError  = true,
            catchIllegal      = true,
            catchUnaligned    = true,
            withLrSc          = true,
            withAmo           = true
          ),
          memoryTranslatorPortConfig = null
      ),

      new CsrPlugin(CsrPluginConfig.smallest(mtvecInit = 0x80000020l)),
      new DecoderSimplePlugin(
        catchIllegalInstruction = true 
      ),
      new StaticMemoryTranslatorPlugin(
        ioRange      = _(31 downto 31) === 0x1
      ),
      new RegFilePlugin(
        regFileReadyKind = plugin.ASYNC,
        zeroBoot = false
      ),
      new IntAluPlugin,
      new SrcPlugin(
        separatedAddSub = false,
        executeInsertion = true 
      ),
      new FullBarrelShifterPlugin,
      new HazardSimplePlugin(
        bypassExecute           = true,
        bypassMemory            = true,
        bypassWriteBack         = true,
        bypassWriteBackBuffer   = true,
        pessimisticUseSrc       = false,
        pessimisticWriteRegFile = false,
        pessimisticAddressMatch = false
      ),
      new MulPlugin,
      new DivPlugin,
      new BranchPlugin(
        earlyBranch = true,
        catchAddressMisaligned = true 
      ),
      new YamlPlugin("cpu0.yaml")
    )
  )

  def fast = {
    val config = default
    //Replace HazardSimplePlugin to get datapath bypass
    config.cpuPlugins(config.cpuPlugins.indexWhere(_.isInstanceOf[HazardSimplePlugin])) = new HazardSimplePlugin(
      bypassExecute = true,
      bypassMemory = true,
      bypassWriteBack = true,
      bypassWriteBackBuffer = true
    )
    config
  }
}


case class VexRiscvForSim(config : RiscvConfig) extends Component{
  import config._

  val io = new Bundle {
    //Clocks / reset
    val asyncReset = in Bool()
    val mainClk = in Bool()
    val iBus = master(Axi4ReadOnly(Axi4Config(addressWidth=32,dataWidth=32,idWidth=1).toFullConfig()))
    val dBus = master(Axi4(Axi4Config(addressWidth=32,dataWidth=32,idWidth=1).toFullConfig()))
  }

  val resetCtrlClockDomain = ClockDomain(
    clock = io.mainClk,
    config = ClockDomainConfig(
      resetKind = BOOT
    )
  )

  val resetCtrl = new ClockingArea(resetCtrlClockDomain) {
    val mainClkResetUnbuffered  = False

    //Implement an counter to keep the reset axiResetOrder high 64 cycles
    // Also this counter will automatically do a reset when the system boot.
    val systemClkResetCounter = Reg(UInt(6 bits)) init(0)
    when(systemClkResetCounter =/= U(systemClkResetCounter.range -> true)){
      systemClkResetCounter := systemClkResetCounter + 1
      mainClkResetUnbuffered := True
    }
    when(BufferCC(io.asyncReset)){
      systemClkResetCounter := 0
    }

    //Create all reset used later in the design
    val mainClkReset = RegNext(mainClkResetUnbuffered)
    val systemReset  = RegNext(mainClkResetUnbuffered)
  }


  val systemClockDomain = ClockDomain(
    clock = io.mainClk,
    reset = resetCtrl.systemReset,
    frequency = FixedFrequency(coreFrequency)
  )

  val system = new ClockingArea(systemClockDomain) {

    val bigEndianDBus = config.cpuPlugins.exists(_ match{ case plugin : DBusSimplePlugin => plugin.bigEndian case _ => false})

    //Instanciate the CPU
    val cpu = new VexRiscv(
      config = VexRiscvConfig(
        plugins = cpuPlugins
      )
    )

    //Checkout plugins used to instanciate the CPU to connect them to the SoC
    val timerInterrupt = False
    val externalInterrupt = False
    var iBus : Axi4ReadOnly = null
    var dBus : Axi4 = null
    for(plugin <- cpu.plugins) plugin match{
      case plugin : IBusCachedPlugin =>
        iBus = plugin.iBus.toAxi4ReadOnly().toFullConfig()
      case plugin : DBusCachedPlugin =>
        dBus = plugin.dBus.toAxi4Shared().toAxi4().toFullConfig()
      case plugin : CsrPlugin        => {
        plugin.externalInterrupt := externalInterrupt
        plugin.timerInterrupt := timerInterrupt
      }
      case _ =>
    }
    io.iBus <> iBus;
    io.dBus <> dBus;
  }
}

object VexRiscvForSim{
  def main(args: Array[String]) {
    SpinalVhdl(VexRiscvForSim(RiscvConfig.default.copy()))
  }
}
