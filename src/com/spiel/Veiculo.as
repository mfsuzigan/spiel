package com.spiel
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	
	public class Veiculo
	{
		private var id:Number;
		private var placa:String;
		
		private var idModelo:String;
		private var nomeModelo:String;
		
		private var nomeMarca:String
		
		private var credito:String;
		private var credito0:String;
		
		private var idCor:String;
		private var nomeCor:String;
		
		private var isento:String;
		private var conexao:Conexao;
		private var stmt:SQLStatement;
		
		// Construtor padrão
		
		public function Veiculo()
		{
			super();
			
			conexao = Conexao.get();
			stmt = new SQLStatement();
			stmt.sqlConnection = conexao;
		}
		
		public function getId():Number 
		{
			return this.id;	
		}
		
		public function setId(id:Number):void
		{
			this.id = id;
		}
		
		// Setter e getter para placa
		
		public function setPlaca(placa:String):void
		{
			this.placa = placa;
		}
		
		public function getPlaca():String
		{
			return placa;
		}
		
		// Setters e getters para idModelo, nomeModelo, nomeMarca
		
		public function setIdModelo(idModelo:String):void
		{
			this.idModelo = idModelo;
			var r:SQLResult;
			var nomeModeloObtido:String;
			var nomeMarcaObtido:String;							
			var stmt:SQLStatement = new SQLStatement();
			
			stmt.sqlConnection = Conexao.get();
			
			stmt.text = "" +
				"SELECT MODELOS.NOME AS NMOD, MARCAS.NOME AS NMARC " + 
				"FROM MODELOS, MARCAS " +
				"WHERE MARCAS.ID = MODELOS.ID_MARCA " +
				"AND MODELOS.ID = " + idModelo + ";";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraSetIdModelo);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraSetIdModeloErro);
			stmt.execute();
			this.nomeModelo = nomeModeloObtido;
			this.nomeMarca = nomeMarcaObtido;
						
			function tratadoraSetIdModelo(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r.data is Object)
				{
					nomeModeloObtido = r.data[0].NMOD;
					nomeMarcaObtido = r.data[0].NMARC;
				}
			}
			
			function tratadoraSetIdModeloErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao estabelecer modelo do veículo: " + event.text);
			}
		}
		
		public function getIdModelo():String
		{
			return idModelo;
		}
		
		public function getNomeModelo():String
		{
			return nomeModelo;
		}
		
		public function getNomeMarca():String
		{
			return nomeMarca;
		}
		
		//Setters e getters para idCor e nomeCor
		
		public function setIdCor(idCor:String):void
		{
			this.idCor = idCor;
			
			var r:SQLResult;
			var nomeCorObtido:String;
			var stmt:SQLStatement = new SQLStatement();
				
			stmt.sqlConnection = Conexao.get();
			stmt.text = "" +
				"SELECT NOME " + 
				"FROM CORES " +
				"WHERE ID = " + idCor + ";";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraSetIdCor);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraSetIdCorErro);
			stmt.execute();
			
			this.nomeCor = nomeCorObtido;
			
			function tratadoraSetIdCor(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r.data is Object)
				
					nomeCorObtido = r.data[0].NOME;
			}
			
			function tratadoraSetIdCorErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao estabelecer cor do veículo: " + event.text);
			}
		}
		
		public function getIdCor():String
		{
			return idCor;
		}
		
		public function getNomeCor():String
		{
			return nomeCor;
		}
		
		//Setter e getter para isento
		
		public function setIsento(isento:String):void
		{
			this.isento = isento;
		}
		
		public function getIsento():String
		{
			return isento;
		}
		
		//Setter e getter para credito
		
		public function setCredito(credito:String):void
		{
			this.credito0 = this.credito is Object ? this.credito : "0";
			this.credito = credito;
		}
		
		public function getCredito():String
		{
			return credito;
		}
		
		// Insere o veiculo no BD
		
		public function inserir():void
		{
			var comandoInserir:String =
				"INSERT " + 
				"INTO VEICULOS (PLACA, ID_MODELO, ID_COR, ISENTO, CREDITO) " +
				"VALUES ('" + this.placa + "', " + this.idModelo + ", " + this.idCor + ", " + this.isento + ", " + this.credito + ");";
				
			var erro:Boolean = false;
			stmt.text = comandoInserir;
			//stmt.addEventListener(SQLEvent.COMMIT, tratadoraInserir);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraInserirErro);
			stmt.execute();
			
			this.atualizarHistoricoDeCreditos();
			
			if (!erro)
				Sugestao.limparDaListaDeSugestoes(this.placa);

			function tratadoraInserir(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraInserirErro(event:SQLErrorEvent):void
			{
				erro = true;
				Alert.show("Erro ao inserir veículo: " + event.error.details);
			}
		}
		
		private function atualizarHistoricoDeCreditos():void
		{
			var comandoInserir:String =
				"INSERT " + 
				"INTO HISTORICO_CREDITOS (T, PLACA, CREDITO, CREDITO_0, VEICULO_ISENTO) " +
				"VALUES ('" + Utils.getStringAgora(true) + "', '" + this.placa + "', " + this.credito + ", " + this.credito0 + ", " + this.getIsento() + ");";
								
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoInserir;
			//stmt.addEventListener(SQLEvent.COMMIT, tratadoraInserir);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraInserirErro);
			stmt.execute();
			
			function tratadoraInserir(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraInserirErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar o histórico de créditos: " + event.error.details);
			}
		}
		
		private function removerDoHistoricoDeCreditos():void
		{
			var comandoRemover:String =
				"DELETE " + 
				"FROM HISTORICO_CREDITOS " +
				"WHERE PLACA = '" + this.placa + "';";
				
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoRemover;
			//stmt.addEventListener(SQLEvent.COMMIT, tratadoraInserir);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRemoverErro);
			stmt.execute();
			
			function tratadoraRemover(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraRemoverErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar o histórico de créditos: " + event.error.details);
			}
		}
		
		// Atualiza dados do veículo no BD.
		
		public function flush(novaPlaca:String):void
		{
			if (novaPlaca != this.placa)
			{
				this.flushMovimentacoes(novaPlaca);
				this.flushAnotacoes(novaPlaca);
			}
			
			var comandoFlush:String =
				"UPDATE VEICULOS " + 
				"SET 	ID_MODELO = " + this.idModelo + ", " + 
						"ID_COR = " + this.idCor + ", " +
						"ISENTO = " + this.isento + ", " + 
						"CREDITO = " + this.credito + ", " + 
						"PLACA = '" + novaPlaca + "' " +
				"WHERE PLACA = '" + this.placa + "';";
				
			stmt.text = comandoFlush;
			stmt.sqlConnection = Conexao.get();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraFlush);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraFlushErro);
			stmt.execute();
			
			this.placa = novaPlaca;
			this.atualizarHistoricoDeCreditos();

			function tratadoraFlush(event:SQLEvent):void
			{
			}
			
			function tratadoraFlushErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar veículo: " + event.error.details);
			}
		}
		
		private function flushMovimentacoes(novaPlaca:String):void
		{
			var comandoFlush:String =
				"UPDATE MOVIMENTACOES " + 
				"SET PLACA = '" + novaPlaca + "' " +
				"WHERE PLACA = '" + this.placa + "';";
				
			stmt.text = comandoFlush;
			stmt.sqlConnection = Conexao.get();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraFlush);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraFlushErro);
			stmt.execute();

			function tratadoraFlush(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraFlushErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar movimentações relacionadas ao veículo: " + event.error.details);
			}
		}
		
		private function flushAnotacoes(novaPlaca:String):void
		{
			var comandoFlush:String =
				"UPDATE ANOTACOES " + 
				"SET PLACA = '" + novaPlaca + "' " +
				"WHERE PLACA = '" + this.placa + "';";
				
			stmt.text = comandoFlush;
			stmt.sqlConnection = Conexao.get();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraFlush);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraFlushErro);
			stmt.execute();

			function tratadoraFlush(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraFlushErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar movimentações relacionadas ao veículo: " + event.error.details);
			}
		}
		
		// Recebendo uma placa, retorna false se não houver
		// veículo registrado sob ela.
		// Se houver, estabelece os atributos de instância
		// com dados do BD.
		
		public function obterDados(placa:String):Boolean
		{
			var comandoObterDados:String =
				"SELECT * " + 
				"FROM VEICULOS " +
				"WHERE PLACA = '" + placa + "';";
				
			var placaObtida:String;
			var idModeloObtido:String;
			var idCorObtido:String;
			var isentoObtido:String
			var creditoObtido:String;
			var idObtido:Number;
			var creditoAnterior:String;
			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterDados);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterDadosErro);
			stmt.execute();
			
			if (r is Object && r.data is Object)
			{
				this.setPlaca(placa);
				this.setIdModelo(idModeloObtido);			
				this.setIdCor(idCorObtido);
				this.setIsento(isentoObtido);
				this.setCredito(creditoObtido);
				this.setId(idObtido);
			}
									
			return (r is Object && r.data is Object);
									
			function tratadoraObterDados(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					idModeloObtido = r.data[0].ID_MODELO;
					idCorObtido = r.data[0].ID_COR;
					isentoObtido = r.data[0].ISENTO;
					creditoObtido = r.data[0].CREDITO;
					idObtido = Number(r.data[0].ID);
				}
			}
			
			function tratadoraObterDadosErro(event:SQLErrorEvent):void
			{
				//Alert.show("Erro ao pesquisar por veículo: " + event.error.details);
			}
		}
					
		public function jaEntrouHoje():Boolean
		{
			var comandoObterDados:String =
				"select placa, t " +
				"from movimentacoes " +
				//"where t = (select max(t) from movimentacoes where placa = p) " +
				"where t like '" + Utils.getStringHojeSemHorario() + "%' " + 
				"and placa = '" + this.placa + "';";
				
			var jaEntrouHoje:Boolean = false;
			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterDados);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterDadosErro);
			stmt.execute();
																				
			return jaEntrouHoje;
									
			function tratadoraObterDados(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					jaEntrouHoje = true;
				}
			}
			
			function tratadoraObterDadosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao pesquisar por veículo: " + event.error.details);
			}
		}
	
		
		// Fecha a conexão (variável de instância).
			
		public function isCreditoInsuficiente():Boolean
		{
			return (Number(this.credito) < Number(Configuracoes.getTarifa()) && Number(this.credito) > 0);
		}
				
		public function remover():void
		{
			this.removerAnotacoesAssociadas();
			this.removerMovimentacoesAssociadas();
			this.removerDoHistoricoDeCreditos();
			
			var comandoRemover:String =			
				"DELETE FROM VEICULOS " +
				"WHERE PLACA = '" + this.placa + "'; ";
				
			stmt.text = comandoRemover;
			stmt.sqlConnection = Conexao.get();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRemover);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRemoverErro);
			stmt.execute();

			function tratadoraRemover(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraRemoverErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao remover veículo: " + event.error.details);
			}
		}
		
		private function removerMovimentacoesAssociadas():void
		{
			var comandoRemover:String =
				"DELETE FROM MOVIMENTACOES " +
				"WHERE PLACA = '" + this.placa + "'; ";
				
			stmt.text = comandoRemover;
			stmt.sqlConnection = Conexao.get();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRemover);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRemoverErro);
			stmt.execute();

			function tratadoraRemover(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraRemoverErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao remover movimentações do veículo: " + event.error.details);
			}
		}
		
		private function removerAnotacoesAssociadas():void
		{
			var comandoRemover:String =
				"DELETE FROM ANOTACOES " +
				"WHERE PLACA = '" + this.placa + "'; ";
				
			stmt.text = comandoRemover;
			stmt.sqlConnection = Conexao.get();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRemover);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRemoverErro);
			stmt.execute();

			function tratadoraRemover(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraRemoverErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao remover anotações do veículo: " + event.error.details);
			}
		}
		
		public static function isPlaca(string:String):Boolean
		{
			return (RegExp)(/^[A-Z]{3} \d{4}$/).test(string);
		}
		
		public static function getNomeMarca(modelo:String):String
		{
			var r:SQLResult;
			var nomeMarcaObtido:String = "";
			var stmt:SQLStatement = new SQLStatement();
			
			stmt.sqlConnection = Conexao.get();
			
			stmt.text = "" +
				"SELECT MARCAS.NOME " + 
				"FROM MODELOS, MARCAS " +
				"WHERE MODELOS.NOME = '" + modelo + "' " +
				"AND MARCAS.ID = MODELOS.ID_MARCA;";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraGetNomeMarca);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraGetNomeMarcaErro);
			stmt.execute();
			
			return nomeMarcaObtido;
			
			function tratadoraGetNomeMarca(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nomeMarcaObtido = String(r.data[0].NOME);
				}
			}
			
			function tratadoraGetNomeMarcaErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao buscar modelo do veículo: " + event.text);
			}
		}
		
		public static function existePlaca(placa:String):Boolean
		{
			var r:SQLResult;
			var stmt:SQLStatement = new SQLStatement();
			var out:Boolean = false;
				
			stmt.sqlConnection = Conexao.get();
			stmt.text = "" +
				"SELECT PLACA " + 
				"FROM VEICULOS " +
				"WHERE PLACA = '" + placa + "';";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraExistePlaca);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraExistePlacaErro);
			stmt.execute();
			
			return out;
			
			function tratadoraExistePlaca(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object && r.data.length == 1)
				
					out = true;
			}
			
			function tratadoraExistePlacaErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao procurar por placa existente: " + event.text);
			}
		}
		
		public static function placasRegistradas():Array
		{
			var r:SQLResult;
			var stmt:SQLStatement = new SQLStatement();
			var placas:Array = new Array();
				
			stmt.sqlConnection = Conexao.get();
			stmt.text = "" +
				"SELECT PLACA " + 
				"FROM VEICULOS ;";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadora);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			stmt.execute();
			
			return placas;
			
			function tratadora(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					for (var i:Number = 0; i < r.data.length; i++)
					{
						placas.push(r.data[i].PLACA.toString());
					}
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar placas existentes: " + event.text);
			}
		}
		
		public static function getIdModelo(modelo:String):String
		{
			var r:SQLResult;
			var idModeloObtido:String = "";
			var stmt:SQLStatement = new SQLStatement();
			
			stmt.sqlConnection = Conexao.get();
			
			stmt.text = "" +
				"SELECT ID " + 
				"FROM MODELOS " +
				"WHERE NOME = '" + modelo + "';";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraGetIdModelo);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraGetIdModeloErro);
			stmt.execute();
			
			return idModeloObtido;
			
			function tratadoraGetIdModelo(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					idModeloObtido = String(r.data[0].ID);
				}
			}
			
			function tratadoraGetIdModeloErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar modelo do veículo: " + event.text);
			}
		}
		
		public static function nroVeiculosNoPatio():Number
		{
			var comandoObterDados:String =
				"SELECT PLACA AS P " +
				"FROM MOVIMENTACOES " +
				"WHERE T = (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) " +
				"AND CODIGO = 1;";
				
			var nroVeiculosNoPatio:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraNoPatio);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraNoPatioErro);
			stmt.execute();
			
			return nroVeiculosNoPatio;
									
			function tratadoraNoPatio(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculosNoPatio = r.data.length;
				}
			}
			
			function tratadoraNoPatioErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos no pátio em um período: " + event.error.details);
			}			
		}
	
		public static function nroVeiculosNoPatioPeriodo(inicio:Date, termino:Date):Number
		{
			var comandoObterDados:String =
				"SELECT PLACA AS P " +
				"FROM MOVIMENTACOES " +
				"WHERE T = (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) " +
				"AND CODIGO = 1 " + 
				"AND T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "';";
				
			var nroVeiculosNoPatio:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraNoPatio);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraNoPatioErro);
			stmt.execute();
			
			return nroVeiculosNoPatio;
									
			function tratadoraNoPatio(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculosNoPatio = r.data.length;
				}
			}
			
			function tratadoraNoPatioErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos no pátio em um período: " + event.error.details);
			}			
		}
		
		public static function nroVeiculosNoPatioHoje():Number
		{
			var strHoje:String = Utils.getStringHojeSemHorario();
			
			var comandoObterDados:String =
				"SELECT PLACA AS P " +
				"FROM MOVIMENTACOES " +
				//"WHERE ID IN (SELECT MAX(ID) FROM MOVIMENTACOES WHERE PLACA = P) " +
				"WHERE NOT EXISTS (SELECT CODIGO FROM MOVIMENTACOES WHERE PLACA = P AND CODIGO = 2 AND T LIKE '" + strHoje  + "%') " +
				"AND CODIGO = 1 " + 
				"AND T LIKE '" + strHoje  + "%';";
				
			/*
			var comandoObterDados:String =
				"SELECT PLACA AS P " +
				"FROM MOVIMENTACOES " +
				//"WHERE T IN (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) " +
				"WHERE CODIGO = 1 " + 
				"AND T LIKE '" + Utils.getStringHojeSemHorario() + "%';";	
				*/
			var nroVeiculosNoPatio:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraNoPatio);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraNoPatioErro);
			stmt.execute();
			
			return nroVeiculosNoPatio;
									
			function tratadoraNoPatio(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculosNoPatio = r.data.length;
				}
			}
			
			function tratadoraNoPatioErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos no pátio hoje: " + event.error.details);
			}			
		}
		
		public static function nroVeiculos():Number
		{
			var comandoObterDados:String =
				"SELECT * FROM VEICULOS;"
				
			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraNroVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraNroVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraNroVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = r.data.length;
				}
			}
			
			function tratadoraNroVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos no pátio: " + event.error.details);
			}			
		}
		
		public static function nroBaixasHoje():Number
		{
			var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			
			var comandoObterDados:String =
				"SELECT PLACA " +
				"FROM MOVIMENTACOES " +
				"WHERE T BETWEEN '" + Utils.getStringDia(hoje) + "' AND '" + Utils.getStringDia(amanha) + "' " +
				"AND CODIGO = 2;";
				
			var nroBaixasHoje:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraBaixasHoje);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraBaixasHojeErro);
			stmt.execute();
			
			return nroBaixasHoje;
									
			function tratadoraBaixasHoje(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroBaixasHoje = r.data.length;
				}
			}
			
			function tratadoraBaixasHojeErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de baixas hoje: " + event.error.details);
			}			
		}
		
		public static function nroBaixas(inicio:Date, termino:Date):Number
		{/*
			var :Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				"SELECT PLACA " +
				"FROM MOVIMENTACOES " +
				"WHERE T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringDia(termino) + "' " +
				"AND CODIGO = 2;";
				
			var nroBaixas:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraBaixas);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraBaixasErro);
			stmt.execute();
			
			return nroBaixas;
									
			function tratadoraBaixas(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroBaixas = r.data.length;
				}
			}
			
			function tratadoraBaixasErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de baixas em período: " + event.error.details);
			}			
		}
		
		public static function nroVeiculosHoje():Number
		{
			var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			
			var comandoObterDados:String =
				"SELECT DISTINCT PLACA " +
				"FROM MOVIMENTACOES " +
				"WHERE T BETWEEN '" + Utils.getStringDia(hoje) + "' AND '" + Utils.getStringDia(amanha) + "';";
				
			var nroVeiculosHoje:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculosHoje);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosHojeErro);
			stmt.execute();
			
			return nroVeiculosHoje;
									
			function tratadoraVeiculosHoje(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculosHoje = r.data.length;
				}
			}
			
			function tratadoraVeiculosHojeErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos hoje: " + event.error.details);
			}			
		}
	
	}
}