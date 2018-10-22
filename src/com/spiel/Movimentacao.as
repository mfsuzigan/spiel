package com.spiel
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	import mx.core.Application;
	
	public class Movimentacao
	{
		private var id:Number;
		private var veiculoAssociado:Veiculo;
		private var tarifaAssociada:Number;
			
		private var t:String;
		
		private var cobrancaNaEntrada:Boolean;
		
		private var codigoMovimentacao:Number;
		private var codigoAnterior:Number;
		
		private var isCreditoDeduzido:Boolean;
			
		private var conexao:Conexao;
		private var stmt:SQLStatement;
		
		public static var COD_REGISTRO:String = "0";
		public static var COD_ENTRADA:String = "1";
		public static var COD_SAIDA:String = "2";
		
		public static var COD_REGISTRO_NUMBER:Number = 0;
		public static var COD_ENTRADA_NUMBER:Number = 1;
		public static var COD_SAIDA_NUMBER:Number = 2;
		
		public function Movimentacao(construtorPadrao:Boolean, veiculo:Veiculo, codigoMovimentacao:Number, codigoAnterior:Number, cobrancaNaEntrada:Boolean)
		{
			super();
			
			if (!construtorPadrao)
			{
				conexao = new Conexao();
				stmt = new SQLStatement();
				stmt.sqlConnection = conexao;
				
				this.codigoMovimentacao = codigoMovimentacao;
				this.codigoAnterior = codigoAnterior;
				this.veiculoAssociado = veiculo;
				this.cobrancaNaEntrada = cobrancaNaEntrada;
				
				// Condições para tarifa zero associada à movimentação:
				
				if (	this.veiculoAssociado.getIsento() == "1" // se o veículo for isento
					|| 	codigoMovimentacao == COD_REGISTRO_NUMBER // se a movimentação for o registro do veículo
					|| 	(codigoMovimentacao == COD_ENTRADA_NUMBER && !cobrancaNaEntrada) // se for uma entrada e a cobrança for na saída
					||	(codigoMovimentacao == COD_SAIDA_NUMBER && cobrancaNaEntrada) // se for uma saída e a cobrança for na entrada 
					)
				{
					this.tarifaAssociada = 0;
				}
				
				// Se a tarifa não for zero, recuperá-la do BD:
				
				else
				{
					this.tarifaAssociada = Number(Configuracoes.getTarifa());
				}				
			}			
		}
		
		public function registrar():Boolean
		{
			var sucesso:Boolean = false;
						
			//****	Query para deduzir créditos do veículo	****//
			
			var creditoDoVeiculo:Number = Number(this.veiculoAssociado.getCredito());
			this.isCreditoDeduzido = (creditoDoVeiculo != 0 && creditoDoVeiculo >= this.tarifaAssociada && this.tarifaAssociada != 0);
			
			this.isCreditoDeduzido = isCreditoDeduzido;
			
			var comandoDeduzCredito:String =
				"UPDATE VEICULOS " + 
				"SET CREDITO = CREDITO - " + this.tarifaAssociada + " " +
				"WHERE PLACA = '" + this.veiculoAssociado.getPlaca() + "' " + 
				"AND CREDITO <> 0 " +
				"AND CREDITO >= " + this.tarifaAssociada + ";";
				
			
			if (!stmt is Object)
				stmt = new SQLStatement();
				
			stmt.text = comandoDeduzCredito;
			stmt.sqlConnection = new Conexao();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraDeduzCredito);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraDeduzCreditoErro);
			stmt.execute();
			
			if (this.isCreditoDeduzido)
			{
				this.veiculoAssociado.setCredito((creditoDoVeiculo - Number(Configuracoes.getTarifa())).toString());
				this.veiculoAssociado.flush(this.veiculoAssociado.getPlaca());
			}
			
			function tratadoraDeduzCredito(event:SQLEvent):void
			{
			}
			
			function tratadoraDeduzCreditoErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao deduzir valor da cobrança dos créditos do veículo: " + event.error.details);
			}
			
			////////////////////////////////////
			
			this.t = Utils.getStringAgora(true);
			var stringIsCreditoDeduzido:String = (isCreditoDeduzido ? "1" : "0");
			
			var comandoInserir:String =
				"INSERT " + 
				"INTO MOVIMENTACOES (T, PLACA, CODIGO, CODIGO0, TARIFA, CRED_DEDUZIDO, VEICULO_ISENTO) " +
				"VALUES ('" + 	this.t 									+ "', " + 
						"'" + 	this.veiculoAssociado.getPlaca() 	+ "', "  
							+	this.codigoMovimentacao				+ ", "	
							+	this.codigoAnterior					+ ", " 	
							+	this.tarifaAssociada				+ ", "
							+	(this.isCreditoDeduzido ? "1" : "0")+ ", "
							+	this.veiculoAssociado.getIsento()	+
				");";
				
			stmt.text = comandoInserir;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraInserir);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraInserirErro);
			stmt.execute();

			function tratadoraInserir(event:SQLEvent):void
			{
				sucesso = true;
			}
			
			function tratadoraInserirErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao inserir movimentação no sistema: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public function registrarCorrecao(t:String):Boolean
		{
			var sucesso:Boolean = false;
						
			//****	Query para deduzir créditos do veículo	****//
			
			var creditoDoVeiculo:Number = Number(this.veiculoAssociado.getCredito());
			this.isCreditoDeduzido = (creditoDoVeiculo != 0 && creditoDoVeiculo >= this.tarifaAssociada && this.tarifaAssociada != 0);
			
			this.isCreditoDeduzido = isCreditoDeduzido;
			
			var comandoDeduzCredito:String =
				"UPDATE VEICULOS " + 
				"SET CREDITO = CREDITO - " + this.tarifaAssociada + " " +
				"WHERE PLACA = '" + this.veiculoAssociado.getPlaca() + "' " + 
				"AND CREDITO <> 0 " +
				"AND CREDITO >= " + this.tarifaAssociada + ";";
				
			stmt.text = comandoDeduzCredito;
			stmt.sqlConnection = new Conexao();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraDeduzCredito);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraDeduzCreditoErro);
			stmt.execute();
			
			if (this.isCreditoDeduzido)
			{
				this.veiculoAssociado.setCredito((creditoDoVeiculo - Number(Configuracoes.getTarifa())).toString());
				this.veiculoAssociado.flush(this.veiculoAssociado.getPlaca());
			}
			
			function tratadoraDeduzCredito(event:SQLEvent):void
			{
			}
			
			function tratadoraDeduzCreditoErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao deduzir valor da cobrança dos créditos do veículo: " + event.error.details);
			}
			
			////////////////////////////////////
			
			this.t = Utils.getStringInstanteFinalDoDia(t);
			var stringIsCreditoDeduzido:String = (isCreditoDeduzido ? "1" : "0");
			
			var comandoInserir:String =
				"INSERT " + 
				"INTO MOVIMENTACOES (T, PLACA, CODIGO, CODIGO0, TARIFA, CRED_DEDUZIDO, VEICULO_ISENTO, ID_VEICULO) " +
				"VALUES ('" + 	this.t 									+ "', " + 
						"'" + 	this.veiculoAssociado.getPlaca() 	+ "', "  
							+	this.codigoMovimentacao				+ ", "	
							+	this.codigoAnterior					+ ", " 	
							+	this.tarifaAssociada				+ ", "
							+	(this.isCreditoDeduzido ? "'1'" : "'0'")+ ", "
							+	this.veiculoAssociado.getIsento()	+ ", "
							+	this.veiculoAssociado.getId()		+
				");";
				
			stmt.text = comandoInserir;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraInserir);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraInserirErro);
			stmt.execute();

			function tratadoraInserir(event:SQLEvent):void
			{
				sucesso = true;
			}
			
			function tratadoraInserirErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao inserir movimentação no sistema: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public static function getVeiculoAssociado(idMovimentacao:String):Veiculo
		{
			var v:Veiculo = new Veiculo();
									
			var comandoVeiculoAssociado:String = "" +
				"SELECT VEICULOS.PLACA " +
				"FROM VEICULOS, MOVIMENTACOES " +
				"WHERE VEICULOS.PLACA = MOVIMENTACOES.PLACA " +
				"AND MOVIMENTACOES.ID = " + idMovimentacao + ";";

			var s:SQLStatement = new SQLStatement();	
			s.text = comandoVeiculoAssociado;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraVeiculoAssociado);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculoAssociadoErro);
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar localizar veículo associado a movimentação: " + erro.message);
			}
			
			s.sqlConnection.close();
			v.fecharConexao();
			return v;
			
			function tratadoraVeiculoAssociado(event:SQLEvent):void
			{
				var r:SQLResult = s.getResult();
				
				try
				{	
					if (r.data is Object)
					
						v.obterDados(r.data[0].PLACA.toString());
						
					else
					
						return;
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar localizar veículo associado a movimentação: " + erro.getStackTrace());
				}
			}
			
			function tratadoraVeiculoAssociadoErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao localizar veículo associado a movimentação: " + event.error.details);	
			}
		}
		
		public static function existeEntrada(idMovimentacao:String):Boolean
		{
			// Recebe um id de movimentação, varre o banco e retorna
			// true, se houver tal movimentação e se o status não for "baixada";
			// false, caso contrário.
			
			var entradaExiste:Boolean = false; 						
			var comandoExisteEntrada:String =
				"SELECT * " + 
				"FROM MOVIMENTACOES " +
				"WHERE ID = " + idMovimentacao  + " " +
				"AND CODIGO = 1;";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoExisteEntrada;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraExisteEntrada);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraExisteEntradaErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				//Alert.show("Erro ao tentar localizar movimentação no banco de dados: " + erro.message);
			}
			
			s.sqlConnection.close();
			return (r is Object && r.data is Object);
			
			function tratadoraExisteEntrada(event:SQLEvent):void
			{
				try
				{
					r = s.getResult();
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar localizar movimentação no banco de dados: " + erro.message);
				}
			}
			
			function tratadoraExisteEntradaErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao localizar movimentação no banco de dados: " + event.error.details);	
			}
			
		}
	
		public static function getCodigoUltimaMovimentacao(placa:String):Number
		{			
			var codigoUltimaMovimentacao:Number = -2;
			 						
			var comandoExisteEntrada:String =
				"SELECT MOVIMENTACOES.CODIGO " + 
				"FROM MOVIMENTACOES, VEICULOS " +
				"WHERE MOVIMENTACOES.PLACA = VEICULOS.PLACA " +
				"AND VEICULOS.PLACA = '" + placa + "' " +
				"AND MOVIMENTACOES.T = (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = '" + placa + "');";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoExisteEntrada;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar localizar última movimentação do veículo no banco de dados: " + erro.message);
			}
			
			s.sqlConnection.close();
			return codigoUltimaMovimentacao;
			
			function tratadora(event:SQLEvent):void
			{
				r = s.getResult();
				
				if (r is Object && r.data is Object)
				{
					codigoUltimaMovimentacao = Number(r.data[0].CODIGO.toString());			
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar localizar última movimentação do veículo no banco de dados: " + event.error.details);
			}			
		}
		
		public static function getIdUltimaMovimentacao(placa:String):Number
		{			
			var idUltimaMovimentacao:Number = -2;
			 						
			var comandoExisteEntrada:String =
				"SELECT MOVIMENTACOES.ID " + 
				"FROM MOVIMENTACOES, VEICULOS " +
				"WHERE MOVIMENTACOES.PLACA = VEICULOS.PLACA " +
				"AND VEICULOS.PLACA = '" + placa + "' " +
				"AND MOVIMENTACOES.T = (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = '" + placa + "');";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoExisteEntrada;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar localizar o identificador da última movimentação do veículo no banco de dados: " + erro.message);
			}
			
			s.sqlConnection.close();
			return idUltimaMovimentacao;
			
			function tratadora(event:SQLEvent):void
			{
				r = s.getResult();
				
				if (r is Object && r.data is Object)
				{
					idUltimaMovimentacao = Number(r.data[0].ID.toString());			
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar localizar o identificador da última movimentação do veículo no banco de dados: " + event.error.details);
			}			
		}
	
		public static function getArrecadacao(inicio:Date, fim:Date):Number
		{
			var arrecadacao:Number = 0;
			 						
			var comandoArrecadacao:String =
				"SELECT SUM(TARIFA) AS SOMA " +
				"FROM MOVIMENTACOES " +
				"WHERE T BETWEEN " + 
					"'" + Utils.getStringInstante(inicio) + 
					"' AND '" + Utils.getStringInstantePreencherCom9s(fim) + "' " +
				"AND CRED_DEDUZIDO = 0;"; //Alert.show(comandoArrecadacao);
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoArrecadacao;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
						
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + erro.message);
			}
			
			s.sqlConnection.close();
			return arrecadacao;
			
			function tratadora(event:SQLEvent):void
			{
				r = s.getResult();
				
				if (r is Object && r.data is Object && r.data[0].SOMA is Object)
				{
					arrecadacao = Number(r.data[0].SOMA.toString());			
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + event.error.details);
			}
		}
		
		public static function getArrecadacaoEntradas(inicio:Date, fim:Date):Number
		{
			var arrecadacao:Number = 0;
			 						
			var comandoArrecadacao:String =
				"SELECT SUM(TARIFA) AS SOMA " +
				"FROM MOVIMENTACOES " +
				"WHERE T BETWEEN " + 
					"'" + Utils.getStringInstante(inicio) + 
					"' AND '" + Utils.getStringInstantePreencherCom9s(fim) + "' " +
				"AND CRED_DEDUZIDO = 0 " + 
				"and codigo = 1;"; //Alert.show(comandoArrecadacao);
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoArrecadacao;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
						
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + erro.message);
			}
			
			s.sqlConnection.close();
			return arrecadacao;
			
			function tratadora(event:SQLEvent):void
			{
				r = s.getResult();
				
				if (r is Object && r.data is Object && r.data[0].SOMA is Object)
				{
					arrecadacao = Number(r.data[0].SOMA.toString());			
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + event.error.details);
			}
		}
		
		public static function getCreditoDistribuido(inicio:Date, termino:Date):Number
		{
			var credito:Number = 0;
			 						
			var comandoCredito:String =
				"select sum(credito - credito_0) as SOMA " +
				"from historico_creditos " +
				"where t between '" + Utils.getStringInstante(inicio)  + "' and '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
				"and credito > credito_0;";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoCredito;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao calcular o crédito distribuído em um intervalo de tempo: " + erro.message);
			}
			
			s.sqlConnection.close();
			return credito;
			
			function tratadora(event:SQLEvent):void
			{
				r = s.getResult();
				
				if (r is Object && r.data is Object && r.data[0].SOMA is Object)
				{
					credito = Number(r.data[0].SOMA.toString());
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + event.error.details);
			}
		}
		
		public static function getCreditoDeduzido(inicio:Date, termino:Date):Number
		{
			var credito:Number = 0;
			 						
			var comandoCredito:String =
				"select sum(credito_0 - credito) as SOMA " +
				"from historico_creditos " +
				"where t between '" + Utils.getStringInstante(inicio)  + "' and '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
				"and credito_0 > credito;";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoCredito;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao calcular o crédito distribuído em um intervalo de tempo: " + erro.message);
			}
			
			s.sqlConnection.close();
			return credito;
			
			function tratadora(event:SQLEvent):void
			{
				r = s.getResult();
				
				if (r is Object && r.data is Object && r.data[0].SOMA is Object)
				{
					credito = Number(r.data[0].SOMA.toString());
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + event.error.details);
			}
		}
	
		public static function getMaxT():String
		{
			var maxT:String;
									
			var comandoMaxT:String =
				"SELECT MAX(T) AS M " + 
				"FROM MOVIMENTACOES;";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoMaxT;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraMaxT);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraMaxTErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar localizar o timestamp máximo das movimentações: " + erro.message);
			}
			
			s.sqlConnection.close();
			return maxT;
			
			function tratadoraMaxT(event:SQLEvent):void
			{
				try
				{
					r = s.getResult();
					
					if (r is Object && r.data is Object)
					{
						maxT = r.data[0].M.toString();
					}
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar localizar o timestamp máximo das movimentações: " + erro.message);
				}
			}
			
			function tratadoraMaxTErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar localizar o timestamp máximo das movimentações: " + event.error.details);	
			}
		}
		
		public static function getMinT():String
		{
			var minT:String;
									
			var comandoMinT:String =
				"SELECT MIN(T) AS M " + 
				"FROM MOVIMENTACOES;";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoMinT;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraMinT);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraMinTErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				//Alert.show("Erro ao tentar localizar o timestamp máximo das movimentações: " + erro.message);
			}
			
			s.sqlConnection.close();
			return minT;
			
			function tratadoraMinT(event:SQLEvent):void
			{
				try
				{
					r = s.getResult();
					
					if (r is Object && r.data is Object)
					{
						minT = r.data[0].M.toString();
					}
				}
				
				catch (erro:Error)
				{
					//Alert.show("Erro ao tentar localizar o timestamp máximo das movimentações: " + erro.message);
				}
			}
			
			function tratadoraMinTErro(event:SQLErrorEvent):void
			{
				//Alert.show("Erro ao tentar localizar o timestamp máximo das movimentações: " + event.error.details);	
			}
		}
		
		public function obterDados(idMovimentacao:String):Boolean
		{
			//var movimentacaoObtida:Movimentacao = null;
			var comandoRecuperar:String =
				"SELECT T, PLACA, CODIGO, CODIGO0, TARIFA, ID, CRED_DEDUZIDO " + 
				"FROM MOVIMENTACOES " +
				"WHERE ID = " + idMovimentacao +
				";";		
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.text = comandoRecuperar;
			stmt.sqlConnection = new Conexao();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			stmt.execute();
			
			var r:SQLResult;
			var codigoAnteriorObtido:Number;
			var codigoMovimentacaoObtido:Number;
			var tObtido:String;
			var veiculoAssociadoObtido:Veiculo;
			var cobrancaNaEntradaObtido:Boolean;
			var isCreditoDeduzidoObtido:Boolean;
			var tarifaAssociadaObtida:Number;
			
			this.codigoAnterior = codigoAnteriorObtido;
			this.codigoMovimentacao = codigoMovimentacaoObtido;
			this.t = tObtido;
			this.veiculoAssociado = veiculoAssociadoObtido;
			this.cobrancaNaEntrada = cobrancaNaEntradaObtido;
			this.isCreditoDeduzido = isCreditoDeduzidoObtido;
			this.tarifaAssociada = tarifaAssociadaObtida;
			
			return (r is Object && r.data is Object);

			function tratadoraRecuperar(event:SQLEvent):void
			{
				r = stmt.getResult();
					
				try
				{	
					if (r.data is Object)
					{
						cobrancaNaEntradaObtido = 
								(r.data[0].CODIGO.toString() == "1" && r.data[0].TARIFA.toString() != 0)
							||	(r.data[0].CODIGO.toString() == "2" && r.data[0].TARIFA.toString() == 0 && Movimentacao.getVeiculoAssociado(r.data[0].ID.toString()).getIsento() != "1")
							;
													
						
						codigoAnteriorObtido = Number(r.data[0].CODIGO0.toString());
						codigoMovimentacaoObtido = Number(r.data[0].CODIGO.toString());
						tObtido = r.data[0].T.toString();
						veiculoAssociadoObtido = Movimentacao.getVeiculoAssociado(idMovimentacao);
						isCreditoDeduzidoObtido = (r.data[0].CRED_DEDUZIDO.toString() == "1");
						tarifaAssociadaObtida = Number(r.data[0].TARIFA.toString());
					}
						
					else
					{
						return;
					}
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar recuperar movimentação no banco de dados: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar recuperar movimentação no banco de dados: " + event.error.details);
			}
		}
		
		public static function nroVeiculosPeriodo(inicio:Date, termino:Date):Number
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				"SELECT PLACA " +
				"FROM MOVIMENTACOES " +
				"WHERE T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
				"AND CODIGO = 1;";

			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = Number(r.data.length.toString());
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos em período: " + event.error.details);
			}			
		}
		
		public static function nroVeiculosNovatosPeriodo(inicio:Date, termino:Date):Number
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				"SELECT PLACA " +
				"FROM MOVIMENTACOES " +
				"WHERE T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
				"AND CODIGO = 0;";

			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = Number(r.data.length.toString());
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos em período: " + event.error.details);
			}			
		}
		
		public static function timestampsPeriodo(inicio:Date, termino:Date):Array
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				
			"SELECT T " +
			"FROM MOVIMENTACOES " +
			"WHERE T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
			"AND CODIGO <> 0 " + 
			"ORDER BY PLACA;";

			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			var saida:Array = new Array();
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return saida;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					for (var i:Number = 0; i < r.data.length; i++)
					{
						saida.push(r.data[i].T.toString());
					}
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar timestamps de veículos em período: " + event.error.details);
			}			
		}
		
		public static function getTimestamps():Array
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				
			"SELECT T " +
			"FROM MOVIMENTACOES " + 
			"ORDER BY T;";

			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			var saida:Array = new Array();
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return saida;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					for (var i:Number = 0; i < r.data.length; i++)
					{
						saida.push(r.data[i].T.toString());
					}
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar timestamps de veículos em período: " + event.error.details);
			}			
		}
		
		public static function nroVeiculosIsentosPeriodo(inicio:Date, termino:Date):Number
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				"select count(*) as C " + 
				"from " + 
				"	(	select placa " + 
				"		from movimentacoes " + 
				"		WHERE T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
				"		and veiculo_isento = 1" +
				"		and codigo = 1" + 
				"	);";
				
			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = Number(r.data[0].C.toString());
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos isentos em período: " + event.error.details);
			}			
		}
		
		public static function nroVeiculosMovimentadosComCreditoPeriodo(inicio:Date, termino:Date):Number
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				"SELECT COUNT(*) as SOMA " + 
				"FROM 	(	SELECT PLACA AS P " + 
				"		FROM MOVIMENTACOES	 " + 
				"		where MOVIMENTACOES.T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
				"		and MOVIMENTACOES.VEICULO_ISENTO = 0  " + 
				"		AND CODIGO = 1 " +  		
				"		AND " + 
				"		( " + 
				"			(TARIFA <> 0 AND CRED_DEDUZIDO = 1)  " + 		
				"			OR  " + 
				"			( " + 
				"				TARIFA = 0  " + 
				"				AND CRED_DEDUZIDO = 0  " + 
				"				AND  " + 	
				"					( " + 
				"						SELECT CREDITO - CREDITO_0  " + 
				"						FROM HISTORICO_CREDITOS  " + 
				"						WHERE PLACA = P  " + 
				"						AND T  BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "' " + 
				"					) > 0 " + 
				"			) " + 
				"		) " + 
				"	);";

			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = Number(r.data[0].SOMA.toString());
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos isentos em período: " + event.error.details);
			}			
		}
		
		
		public static function nroVeiculosCobrancaNaEntradaPeriodo(inicio:Date, termino:Date):Number
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				"SELECT COUNT(*) AS SOMA " +
				"FROM MOVIMENTACOES " +
				"WHERE CODIGO = 1 " +
				"AND VEICULO_ISENTO = 0 " +
				"AND CRED_DEDUZIDO = 0 " +
				"and T BETWEEN '" + Utils.getStringDia(inicio) + "' AND '" + Utils.getStringInstantePreencherCom9s(termino) + "' " +
				"AND TARIFA <> 0;";
				
			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = Number(r.data[0].SOMA.toString());
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos isentos em período: " + event.error.details);
			}			
		}
		
		
		public function getId():String
		{
			return this.id.toString();
		}
		
		public function getVeiculoAssociado():Veiculo
		{
			return this.veiculoAssociado;
		}
		
		public function getTarifaAssociada():Number
		{
			return this.tarifaAssociada
		}
		
		public function getT():String
		{
			return this.t;
		}
		
		public function getCodigoMovimentacao():String
		{
			return this.codigoMovimentacao.toString();
		}
		
		public function getCodigoAnterior():String
		{
			return this.codigoAnterior.toString();
		}
	
		public function getCobrancaNaEntrada():Boolean
		{
			return this.cobrancaNaEntrada;
		}
	
		public function creditoFoiDeduzido():Boolean
		{
			return this.isCreditoDeduzido;
		}
		
		public function desfazer():Boolean
		{	
			var sucesso:Boolean = false;	
			var comandoDesfazer:String;
			var veiculo:Veiculo = this.getVeiculoAssociado();
			
			comandoDesfazer = 
				"DELETE FROM MOVIMENTACOES " + 
				"WHERE T = '" + this.t + "';";
			
			/*				
			if (this.codigoMovimentacao == Movimentacao.COD_REGISTRO_NUMBER) // Registro
			{
				veiculo.remover();
			}
			*/
			
			// Se se desfaz a única movimentação de entrada de um veículo, ele é excluído,
			// para evitar um "limbo" de status.
			
			if (		this.codigoMovimentacao == Movimentacao.COD_ENTRADA_NUMBER
					&&	this.codigoAnterior == Movimentacao.COD_REGISTRO_NUMBER
				) 
			{	
				veiculo.remover();
			}
			
			else if (		this.codigoMovimentacao == Movimentacao.COD_ENTRADA_NUMBER 
						|| 	this.codigoMovimentacao == Movimentacao.COD_SAIDA_NUMBER
					) // Entrada ou saída
			{
				if (this.isCreditoDeduzido)
				{
					var novoCredito:Number = Number(veiculo.getCredito()) + this.getTarifaAssociada();
					veiculo.setCredito(novoCredito.toString());
					veiculo.flush(veiculo.getPlaca());
				}
			}
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoDesfazer;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraDesfazer);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraDesfazerErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao desfazer ação: " + erro.message);
			}
			
			s.sqlConnection.close();
			return sucesso;
			
			function tratadoraDesfazer(event:SQLEvent):void
			{
				try
				{
					r = s.getResult();
					
					sucesso = true;
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao desfazer ação: " + erro.message);
				}
			}
			
			function tratadoraDesfazerErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao desfazer ação: " + event.error.details);	
			}
			
		}
		
		public static function placasDeVeiculosNoPatio():Array
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			var comandoObterDados:String =
				"SELECT PLACA AS P " +
				"FROM MOVIMENTACOES " +
				"WHERE T = (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) " + 
				"AND CODIGO = 1;";
		
			var placas:Array = new Array();			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return placas;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					for (var i:Number = 0; i < r.data.length; i++)
					{
						placas.push(r.data[i].P.toString());
					}
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar placas de veículos no pátio: " + event.error.details);
			}			
		}
		
		public static function getTPrimeiraEntrada(dia:Date):String
		{
			var tDia:String = Utils.getStringDia(dia);
			var tPrimeiraEntrada:String = null;
									
			var comando:String =
				"SELECT MIN(T) AS M " + 
				"FROM MOVIMENTACOES " + 
				"where t >= '" + tDia + "' " + 
				"and codigo = 1;";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comando;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar localizar o timestamp da primeira entrada para o dia: " + erro.message);
			}
			
			s.sqlConnection.close();
			return tPrimeiraEntrada;
			
			function tratadora(event:SQLEvent):void
			{
				try
				{
					r = s.getResult();
					
					if (r is Object && r.data is Object)
					{
						tPrimeiraEntrada = r.data[0].M.toString();
					}
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar localizar o timestamp da primeira entrada para o dia: " + erro.message);
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar localizar o timestamp da primeira entrada para o dia: " + event.error.details);	
			}
		}
		
		public static function getTUltimaSaida(dia:Date):String
		{
			var tDia:String = Utils.getStringInstantePreencherCom9s(dia);
			var tUltimaSaida:String = null;
									
			var comando:String =
				"SELECT MAX(T) AS M " + 
				"FROM MOVIMENTACOES " + 
				"where t <= '" + tDia + "' " + 
				"and codigo = 2;";
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comando;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadora);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar localizar o timestamp da última saída para o dia: " + erro.message);
			}
			
			s.sqlConnection.close();
			return tUltimaSaida;
			
			function tratadora(event:SQLEvent):void
			{
				try
				{
					r = s.getResult();
					
					if (r is Object && r.data is Object)
					{
						tUltimaSaida = r.data[0].M.toString();
					}
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar localizar o timestamp da última saída para o dia: " + erro.message);
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar localizar o timestamp da última saída para o dia: " + event.error.details);	
			}
		}
		
		public function obterDadosPorTimestamp(t:String):Boolean
		{
			//var movimentacaoObtida:Movimentacao = null;
			var comandoRecuperar:String =
				"SELECT T, PLACA, CODIGO, CODIGO0, TARIFA, ID, CRED_DEDUZIDO " + 
				"FROM MOVIMENTACOES " +
				"WHERE T = '" + t +	"';";		
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.text = comandoRecuperar;
			stmt.sqlConnection = new Conexao();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			
			var r:SQLResult;
			var codigoAnteriorObtido:Number;
			var codigoMovimentacaoObtido:Number;
			var tObtido:String;
			var veiculoAssociadoObtido:Veiculo = new Veiculo();
			var cobrancaNaEntradaObtido:Boolean;
			var isCreditoDeduzidoObtido:Boolean;
			var tarifaAssociadaObtida:Number;
			var idObtido:Number
			
			stmt.execute();
			
			this.codigoAnterior = codigoAnteriorObtido;
			this.codigoMovimentacao = codigoMovimentacaoObtido;
			this.t = tObtido;
			this.veiculoAssociado = veiculoAssociadoObtido;
			this.cobrancaNaEntrada = cobrancaNaEntradaObtido;
			this.isCreditoDeduzido = isCreditoDeduzidoObtido;
			this.tarifaAssociada = tarifaAssociadaObtida;
			this.id = idObtido;
			
			return (r is Object && r.data is Object);

			function tratadoraRecuperar(event:SQLEvent):void
			{
				r = stmt.getResult();
					
				try
				{	
					if (r.data is Object)
					{
						cobrancaNaEntradaObtido = 
								(r.data[0].CODIGO.toString() == "1" && r.data[0].TARIFA.toString() != 0)
							||	(r.data[0].CODIGO.toString() == "2" && r.data[0].TARIFA.toString() == 0 && Movimentacao.getVeiculoAssociado(r.data[0].ID.toString()).getIsento() != "1")
							;
													
						
						codigoAnteriorObtido = Number(r.data[0].CODIGO0.toString());
						codigoMovimentacaoObtido = Number(r.data[0].CODIGO.toString());
						tObtido = r.data[0].T.toString();
						veiculoAssociadoObtido.obterDados(r.data[0].PLACA.toString());
						isCreditoDeduzidoObtido = (r.data[0].CRED_DEDUZIDO.toString() == "1");
						tarifaAssociadaObtida = Number(r.data[0].TARIFA.toString());
						idObtido = Number(r.data[0].ID.toString());
					}
						
					else
					{
						return;
					}
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar recuperar movimentação no banco de dados: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar recuperar movimentação no banco de dados: " + event.error.details);
			}
		}
		
		public function obterDadosPorTimestampComConexao(t:String, conexao:SQLConnection):Boolean
		{
			//var movimentacaoObtida:Movimentacao = null;
			var comandoRecuperar:String =
				"SELECT T, PLACA, CODIGO, CODIGO0, TARIFA, ID, CRED_DEDUZIDO " + 
				"FROM MOVIMENTACOES " +
				"WHERE T = '" + t +	"';";		
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.text = comandoRecuperar;
			stmt.sqlConnection = conexao;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			
			var r:SQLResult;
			var codigoAnteriorObtido:Number;
			var codigoMovimentacaoObtido:Number;
			var tObtido:String;
			var veiculoAssociadoObtido:Veiculo = new Veiculo();
			var cobrancaNaEntradaObtido:Boolean;
			var isCreditoDeduzidoObtido:Boolean;
			var tarifaAssociadaObtida:Number;
			var idObtido:Number
			
			stmt.execute();
			
			this.codigoAnterior = codigoAnteriorObtido;
			this.codigoMovimentacao = codigoMovimentacaoObtido;
			this.t = tObtido;
			this.veiculoAssociado = veiculoAssociadoObtido;
			this.cobrancaNaEntrada = cobrancaNaEntradaObtido;
			this.isCreditoDeduzido = isCreditoDeduzidoObtido;
			this.tarifaAssociada = tarifaAssociadaObtida;
			this.id = idObtido;
			
			return (r is Object && r.data is Object);

			function tratadoraRecuperar(event:SQLEvent):void
			{
				r = stmt.getResult();
					
				try
				{	
					if (r.data is Object)
					{
						cobrancaNaEntradaObtido = 
								(r.data[0].CODIGO.toString() == "1" && r.data[0].TARIFA.toString() != 0)
							||	(r.data[0].CODIGO.toString() == "2" && r.data[0].TARIFA.toString() == 0 && Movimentacao.getVeiculoAssociado(r.data[0].ID.toString()).getIsento() != "1")
							;
													
						
						codigoAnteriorObtido = Number(r.data[0].CODIGO0.toString());
						codigoMovimentacaoObtido = Number(r.data[0].CODIGO.toString());
						tObtido = r.data[0].T.toString();
						veiculoAssociadoObtido.obterDados(r.data[0].PLACA.toString());
						isCreditoDeduzidoObtido = (r.data[0].CRED_DEDUZIDO.toString() == "1");
						tarifaAssociadaObtida = Number(r.data[0].TARIFA.toString());
						idObtido = Number(r.data[0].ID.toString());
					}
						
					else
					{
						return;
					}
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar recuperar movimentação no banco de dados: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao tentar recuperar movimentação no banco de dados: " + event.error.details);
			}
		}
		
		public function registrarComT(timestamp:String):Boolean
		{
			var sucesso:Boolean = false;
						
			//****	Query para deduzir créditos do veículo	****//
			
			var creditoDoVeiculo:Number = Number(this.veiculoAssociado.getCredito());
			this.isCreditoDeduzido = (creditoDoVeiculo != 0 && creditoDoVeiculo >= this.tarifaAssociada && this.tarifaAssociada != 0);
			
			this.isCreditoDeduzido = isCreditoDeduzido;
			
			var comandoDeduzCredito:String =
				"UPDATE VEICULOS " + 
				"SET CREDITO = CREDITO - " + this.tarifaAssociada + " " +
				"WHERE PLACA = '" + this.veiculoAssociado.getPlaca() + "' " + 
				"AND CREDITO <> 0 " +
				"AND CREDITO >= " + this.tarifaAssociada + ";";
				
			
			if (!stmt is Object)
				stmt = new SQLStatement();
				
			stmt.text = comandoDeduzCredito;
			stmt.sqlConnection = new Conexao();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraDeduzCredito);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraDeduzCreditoErro);
			stmt.execute();
			
			if (this.isCreditoDeduzido)
			{
				this.veiculoAssociado.setCredito((creditoDoVeiculo - Number(Configuracoes.getTarifa())).toString());
				this.veiculoAssociado.flush(this.veiculoAssociado.getPlaca());
			}
			
			function tratadoraDeduzCredito(event:SQLEvent):void
			{
			}
			
			function tratadoraDeduzCreditoErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao deduzir valor da cobrança dos créditos do veículo: " + event.error.details);
			}
			
			////////////////////////////////////
			
			this.t = timestamp;
			var stringIsCreditoDeduzido:String = (isCreditoDeduzido ? "1" : "0");
			
			var comandoInserir:String =
				"INSERT " + 
				"INTO MOVIMENTACOES (T, PLACA, CODIGO, CODIGO0, TARIFA, CRED_DEDUZIDO, VEICULO_ISENTO) " +
				"VALUES ('" + 	this.t 									+ "', " + 
						"'" + 	this.veiculoAssociado.getPlaca() 	+ "', "  
							+	this.codigoMovimentacao				+ ", "	
							+	this.codigoAnterior					+ ", " 	
							+	this.tarifaAssociada				+ ", "
							+	(this.isCreditoDeduzido ? "1" : "0")+ ", "
							+	this.veiculoAssociado.getIsento()	+
				");";
				
			stmt.text = comandoInserir;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraInserir);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraInserirErro);
			stmt.execute();

			function tratadoraInserir(event:SQLEvent):void
			{
				sucesso = true;
			}
			
			function tratadoraInserirErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao inserir movimentação no sistema: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public static function nroVeiculosDeOutroDiaNoPatio():Number
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			
			var tHoje:String = Utils.getStringDiaSemHorario(new Date());
			
			var comandoObterDados:String =
				
			"select placa as p, t " +
			"from movimentacoes " +
			"where t = (select max(t) from movimentacoes where placa = p) " + 
			"and t not like '" + tHoje + "%'" +
			"and codigo = 1;";

			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = r.data.length;
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de veículos no pátio remanescentes de outros dias: " + event.error.details);
			}			
		}
		
		public static function nroMovimentacoesPorMes():Array
		{
			var comandoObterDados:String =
				
			"select distinct substr(t, 1, 6) as MES, count(*) as NMOVS " +
			"from movimentacoes " + 
			"where codigo = 1 " + 
			"group by MES;";
		
			var movs:Array = new Array();
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadora);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			stmt.execute();
			
			return movs;
									
			function tratadora(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					for (var i:Number = 0; i < r.data.length; i++)
					{
						var tupla:Object = new Object();
												
						tupla.t = r.data[i].MES.toString();
						tupla.mes = Application.application.nomesDeMeses[Number(String(r.data[i].MES).substr(4, 2)) - 1] 
							+ "/" 
							+ String(r.data[i].MES).substring(0, 4);
						
						tupla.nroMovimentacoes = r.data[i].NMOVS.toString();
						
						movs.push(tupla);
					}
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar número de movimentações por mês: " + event.error.details);
			}			
		}
		
		public static function nroMovimentacoesDeletaveis():Number
		{
			/*var hoje:Date = new Date();
			var amanha:Date = new Date();
			amanha.setDate(amanha.date + 1);			
			*/
			
			var tHoje:String = Utils.getStringDiaSemHorario(new Date());
			
			var comandoObterDados:String =
				
			"select count(*) as C " +
			"from movimentacoes " +
			"where codigo <> 0;";

			var nroVeiculos:Number = 0;			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraVeiculos);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraVeiculosErro);
			stmt.execute();
			
			return nroVeiculos;
									
			function tratadoraVeiculos(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroVeiculos = Number(r.data[0].C.toString());
				}
			}
			
			function tratadoraVeiculosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao limpar histórico: " + event.error.details);
			}			
		}
		/*
		
		public function excluirMovimentacoesDeMes(tMes:String):Boolean
		{	
			var sucesso:Boolean = false;	
			var comandoDesfazer:String;
			var veiculo:Veiculo = this.getVeiculoAssociado();
			
			comandoDesfazer = 
				"DELETE FROM MOVIMENTACOES " + 
				"WHERE T LIKE '" + tMes + "%' " + 
				"AND (CODIGO = 1 OR CODIGO = 2);";
			
			
			
			// Se se desfaz a única movimentação de entrada de um veículo, ele é excluído,
			// para evitar um "limbo" de status.
			
			if (		this.codigoMovimentacao == Movimentacao.COD_ENTRADA_NUMBER
					&&	this.codigoAnterior == Movimentacao.COD_REGISTRO_NUMBER
				) 
			{	
				veiculo.remover();
			}
			
			else if (		this.codigoMovimentacao == Movimentacao.COD_ENTRADA_NUMBER 
						|| 	this.codigoMovimentacao == Movimentacao.COD_SAIDA_NUMBER
					) // Entrada ou saída
			{
				if (this.isCreditoDeduzido)
				{
					var novoCredito:Number = Number(veiculo.getCredito()) + this.getTarifaAssociada();
					veiculo.setCredito(novoCredito.toString());
					veiculo.flush(veiculo.getPlaca());
				}
			}
			
			var s:SQLStatement = new SQLStatement();	
			s.text = comandoDesfazer;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraDesfazer);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraDesfazerErro);
			
			var r:SQLResult;
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao desfazer ação: " + erro.message);
			}
			
			s.sqlConnection.close();
			return sucesso;
			
			function tratadoraDesfazer(event:SQLEvent):void
			{
				try
				{
					r = s.getResult();
					
					sucesso = true;
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao desfazer ação: " + erro.message);
				}
			}
			
			function tratadoraDesfazerErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao desfazer ação: " + event.error.details);	
			}
			
		}*/
	}
}

