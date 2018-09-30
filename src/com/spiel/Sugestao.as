package com.spiel
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	
	public class Sugestao
	{
		private var nomeCor:String;
		private var nomeModelo:String;
		private var placa:String;
		
		public function Sugestao(placa:String)
		{
			var nomeModelo:String = "";
			var nomeCor:String = "";
			
			var r:SQLResult;
			var stmt:SQLStatement = new SQLStatement();
				
			stmt.sqlConnection = new Conexao();
			stmt.text = "" +
				"SELECT * " + 
				"FROM SUGESTOES " +
				"WHERE PLACA = '" + placa + "';";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraExistePlaca);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraExistePlacaErro);
			stmt.execute();
			stmt.sqlConnection.close();
			
			this.nomeCor = nomeCor;
			this.nomeModelo = nomeModelo;
			this.placa = placa;
						
			function tratadoraExistePlaca(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object && r.data.length == 1)
				{
					placa = r.data[0].PLACA.toString();
					
					nomeModelo = (r.data[0].NOME_MODELO is Object)
						? r.data[0].NOME_MODELO.toString()
						: "";
						
					nomeCor = (r.data[0].NOME_COR is Object)
						? r.data[0].NOME_COR.toString()
						: "";
				}
			}
			
			function tratadoraExistePlacaErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao procurar por placa existente: " + event.text);
			}
		}
		
		public static function isPlacaSugestao(placa:String):Boolean
		{
			var r:SQLResult;
			var stmt:SQLStatement = new SQLStatement();
			var out:Boolean = false;
				
			stmt.sqlConnection = new Conexao();
			stmt.text = "" +
				"SELECT PLACA " + 
				"FROM SUGESTOES " +
				"WHERE PLACA = '" + placa + "';";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraExistePlaca);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraExistePlacaErro);
			stmt.execute();
			stmt.sqlConnection.close();
			
			return out;
			
			function tratadoraExistePlaca(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object && r.data.length == 1)
				
					out = true;
			}
			
			function tratadoraExistePlacaErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao procurar por sugestão de placa: " + event.text);
			}
		}
		
		public static function limparDaListaDeSugestoes(placa:String):void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			
			var comandoLimpar:String =
				"DELETE " + 
				"FROM SUGESTOES " +
				"WHERE PLACA = '" + placa  + "';";
			
			stmt.text = comandoLimpar;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraLimpar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraLimparErro);
			stmt.execute();

			function tratadoraLimpar(event:SQLEvent):void
			{
				//Alert.show("Veículo inserido.");
			}
			
			function tratadoraLimparErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao limpar lista de sugestões: " + event.error.details);
			}
		}
		
		public function getNomeModelo():String
		{
			return this.nomeModelo;
		}
		
		public function getNomeCor():String
		{
			return this.nomeCor;
		}
	}
}