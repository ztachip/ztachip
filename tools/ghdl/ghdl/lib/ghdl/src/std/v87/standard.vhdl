package standard is
  type boolean is (false, true);
  type bit is ('0', '1');
  type character is (nul, soh, stx, etx, eot, enq, ack, bel, bs, ht, lf, vt, ff, cr, so, si, dle, dc1, dc2, dc3, dc4, nak, syn, etb, can, em, sub, esc, fsp, gsp, rsp, usp, ' ', '!', '"', '#', '$', '%', '&', ''', '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\', ']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~', del);
  type severity_level is (note, warning, error, failure);
  type UNIVERSAL_INTEGER is range -9223372036854775808 to 9223372036854775807;
  type UNIVERSAL_REAL is range -1.79769313486232E+308 to 1.79769313486232E+308;
  type integer is range -2147483648 to 2147483647;
  type real is range -1.79769313486232E+308 to 1.79769313486232E+308;
  type time is range -9223372036854775808 fs to 9223372036854775807 fs units
    fs;
    ps = 1000 fs;
    ns = 1000 ps;
    us = 1000 ns;
    ms = 1000 us;
    sec = 1000 ms;
    min = 60 sec;
    hr = 60 min;
  end units;
  function now return time;
  subtype natural is integer range 0 to 2147483647;
  subtype positive is integer range 1 to 2147483647;
  type string is array (positive range <>) of character;
  type bit_vector is array (natural range <>) of bit;
end;

