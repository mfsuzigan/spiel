package com.spiel
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;

	public class Cor
	{
		public function Cor()
		{
		}
		
		public static function getNome(codCor:String):String
		{
			var r:SQLResult;					
			var stmt:SQLStatement = new SQLStatement();			
			stmt.sqlConnection = new Conexao();
			
			var nomeCor:String = "";
			
			stmt.text = "" +
				"SELECT NOME " + 
				"FROM CORES " +
				"WHERE ID = '" + codCor + "';";
				
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraGetNome);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraGetNomeErro);
			stmt.execute();
			stmt.sqlConnection.close();
			
			return nomeCor;
									
			function tratadoraGetNome(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nomeCor = r.data[0].NOME;
				}
			}
			
			function tratadoraGetNomeErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao pesquisar por designação de cor: " + event.text);
			}
		}
		
		public static function getNomesCores():Array
		{
			var nomesDeCores:Array = new Array();
									
			var comandoRecuperar:String = "" +
				"SELECT NOME " +
				"FROM CORES ORDER BY NOME;";

			var s:SQLStatement = new SQLStatement();	
			s.text = comandoRecuperar;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			//Alert.show();
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar levantar nomes de cores de veículos: " + erro.message);
			}
			
			s.sqlConnection.close();
			
			function tratadoraRecuperar(event:SQLEvent):void
			{
				var r:SQLResult = s.getResult();
				
				try
				{	
					if (r is Object && r.data is Object)
					{
						for (var i:Number = 0; i < r.data.length; i++)
						{
							nomesDeCores.push(r.data[i].NOME.toString());							
						}
					}					
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar levantar nomes de cores de veículos: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar nomes de cores de veículos: " + event.error.details);	
			}

			return nomesDeCores;
		}
		
		public static function getCodigo(nomeCor:String):String
		{
			var r:SQLResult;					
			var stmt:SQLStatement = new SQLStatement();			
			stmt.sqlConnection = new Conexao();

			var codCor:String = "";
			
			stmt.text = "" +
				"SELECT ID " + 
				"FROM CORES " +
				"WHERE NOME = '" + nomeCor + "';";
				
			stmt.addEventListener(SQLEvent.RESULT, tratadoraGetCodigo);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraGetCodigoErro);
			stmt.execute();
			stmt.sqlConnection.close();
			
			return codCor;
									
			function tratadoraGetCodigo(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					codCor = r.data[0].ID;
				}
			}
			
			function tratadoraGetCodigoErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao pesquisar por código hex de cor: " + event.text);
			}
		}
	}
}