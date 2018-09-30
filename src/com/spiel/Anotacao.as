package com.spiel
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	
	public class Anotacao
	{
		private var titulo:String;
		private var texto:String;
		private var placaAssociada:String;
		private var idMovimentacaoAssociada:String;
		private var t:String;
		
		public function Anotacao(construtorPadrao:Boolean, titulo:String, texto:String, placa:String, idMovimentacao:String)
		{
			if (!construtorPadrao)
			{
				this.titulo = titulo;
				this.texto = texto;
				this.placaAssociada = placa;
				this.idMovimentacaoAssociada = idMovimentacao;
				
				if (idMovimentacao == "")
				{
					this.idMovimentacaoAssociada = "-1";
				}
				
				this.t = Utils.getStringAgora(false);
			}
		}
		
		public function obterDados(t:String):Boolean
		{
			var comandoObterDados:String =
				"SELECT * " + 
				"FROM ANOTACOES " +
				"WHERE T = '" + t + "';";
				
			var tituloObtido:String;
			var textoObtido:String;
			var placaObtida:String;
			var idMovimentacaoObtida:String;
			
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterDados);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterDadosErro);
			stmt.execute();
			
			this.t = t;
			this.titulo= tituloObtido;
			this.texto = textoObtido;/*
			this.veiculoAssociado = null;
			this.movimentacaoAssociada = null;*/
			this.placaAssociada = placaObtida;
			this.idMovimentacaoAssociada = idMovimentacaoObtida;
									
			return (r is Object && r.data is Object);
									
			function tratadoraObterDados(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					tituloObtido = r.data[0].TITULO.toString();
					textoObtido = r.data[0].TEXTO.toString();
					idMovimentacaoObtida = (r.data[0].ID_MOV is Object) ? r.data[0].ID_MOV.toString() : "-1";
					placaObtida = (r.data[0].PLACA is Object) ? r.data[0].PLACA.toString() : "";
				}
			}
			
			function tratadoraObterDadosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar informações da anotação: " + event.error.details);
			}
		}
	
		public function registrar():Boolean
		{
			var sucesso:Boolean = false;
						
			var comandoInserir:String =
				"INSERT " + 
				"INTO ANOTACOES (T, PLACA, ID_MOV, TITULO, TEXTO) " +
				"VALUES ('" + 	this.t + "', " + 
						"'" + 	this.placaAssociada + "', " +
						this.idMovimentacaoAssociada + ", "	+
						"'"	+	this.titulo	+ "', " +	
						"'"	+	this.texto	+ "'" +
				");"
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
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
				Alert.show("Erro ao inserir anotação no sistema: " + event.error.details);
			}
			
			return sucesso;
		}

		public function flush():Boolean
		{
			var sucesso:Boolean = false;
						
			var comandoFlush:String =
				"UPDATE ANOTACOES " + 
				"SET 	PLACA = '" + this.placaAssociada + "', " + 
						"ID_MOV = " + this.idMovimentacaoAssociada + ", " +
						"TITULO = '" + this.titulo + "', " + 
						"TEXTO = '" + this.texto + "' " +
				"WHERE T = '" + this.t + "';";
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoFlush;
			stmt.addEventListener(SQLEvent.RESULT, tratadora);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			stmt.execute();

			function tratadora(event:SQLEvent):void
			{
				sucesso = true;
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar dados da anotação: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public function deletar():Boolean
		{
			var comandoDeletar:String =
				"DELETE " + 
				"FROM ANOTACOES " +
				"WHERE T = '" + this.t + "';";
							
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoDeletar;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraDeletar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraDeletarErro);
			stmt.execute();
									
			return (r is Object);
									
			function tratadoraDeletar(event:SQLEvent):void
			{
				r = stmt.getResult();
			}
			
			function tratadoraDeletarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao deletar anotação: " + event.error.details);
			}
		}
		
		public static function deletarAnotacoes():Boolean
		{
			var comandoDeletar:String =
				"DELETE " + 
				"FROM ANOTACOES;";
							
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoDeletar;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraDeletar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraDeletarErro);
			stmt.execute();
									
			return (r is Object);
									
			function tratadoraDeletar(event:SQLEvent):void
			{
				r = stmt.getResult();
			}
			
			function tratadoraDeletarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao deletar todas as anotações: " + event.error.details);
			}
		}
		
		public function getT():String
		{
			return this.t;
		}
		/*
		public function getIndiceCorrespondenteNaTabela():Number
		{
			var i:Number = -1;
			
			return i;
		}
	*/
		public function setTitulo(titulo:String):void
		{
			this.titulo = titulo;
		}
		
		public function setTexto(texto:String):void
		{
			this.texto = texto;
		}
		
		public function setPlacaAssociada(placa:String):void
		{
			this.placaAssociada = placa;
		}
		
		public function setIdMovimentacaoAssociada(idMovimentacao:String):void
		{
			this.idMovimentacaoAssociada = idMovimentacao;
		}
	
		public static function getNroAnotacoesAssociadas(input:String):Number
		{
			if (input == "" || input == "-1")
			
				return 0;
			
			var isInputPlaca:Boolean = Veiculo.isPlaca(input);
			var nroAnotacoes:Number = 0;
			
			var comandoObterDados:String =
			"SELECT * " + 
			"FROM ANOTACOES " +
			"WHERE " +
				(isInputPlaca ? "PLACA = '" : "ID_MOV = '") 
				+ input + "';";
							
			var r:SQLResult;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterDados;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterDados);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterDadosErro);
			stmt.execute();
													
			return nroAnotacoes;
									
			function tratadoraObterDados(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nroAnotacoes = r.data.length;
				}
			}
			
			function tratadoraObterDadosErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar o número de anotações associadas à entrada: " + event.error.details);
			}
		}
	
		public static function getIndicesAnotacoesAssociadas(input:String):Array
		{
			var indicesObtidos:Array = new Array();
			var isInputPlaca:Boolean = Veiculo.isPlaca(input);
			
			//////////// Primeira parte
			
			var comandoObterTs:String =
			"SELECT T " + 
			"FROM ANOTACOES " +
			"WHERE " +
				(isInputPlaca ? "PLACA = '" : "ID_MOV = '") 
				+ input + "';";
			
			var stringsComandosObtidos:Array = new Array();
							
			var r:SQLResult;			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoObterTs;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterTs);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterTsErro);
			stmt.execute();
			
			var rInterno:SQLResult;	
			
			for (var j:Number = 0; j < stringsComandosObtidos.length; j++)
			{
				var stmtInterno:SQLStatement = new SQLStatement();
				stmtInterno.sqlConnection = new Conexao();
				stmtInterno.addEventListener(SQLEvent.RESULT, tratadoraObterIndices);
				stmtInterno.addEventListener(SQLErrorEvent.ERROR, tratadoraObterIndicesErro);
				stmtInterno.text = stringsComandosObtidos[j].toString();
				stmtInterno.execute();
			}
			
			return indicesObtidos;								
																							
			function tratadoraObterTs(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				var comecoComandoObterIndices:String =
				"SELECT COUNT(*) AS C " + 
				"FROM ANOTACOES " +
				"WHERE T > '";
				
				if (r is Object && r.data is Object)
				{
					for (var i:Number = 0; i < r.data.length; i++)
					{						
						var comandoObterIndices:String = 
								comecoComandoObterIndices +
								r.data[i].T.toString() +
								"';";
							
						stringsComandosObtidos.push(comandoObterIndices);
					}
				}
			}
			
			function tratadoraObterTsErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao obter as chaves primárias das anotações associadas à entrada: " + event.error.details);
			}
		
			function tratadoraObterIndices(event:SQLEvent):void
			{
				rInterno = stmtInterno.getResult();
				
				if (rInterno is Object && rInterno.data is Object)
				{
					indicesObtidos.push(Number(rInterno.data[0].C.toString()));
				}
			}
			
			function tratadoraObterIndicesErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao obter os índices de anotações anteriores às anotações associadas à entrada: " + event.error.details);
			}
		}
	}
}