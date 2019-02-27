package com.spiel
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	
	public class Configuracoes
	{
		public function Configuracoes()
		{
		}

		public static function getTarifa():String
		{
			var comandoObterTarifa:String =
				"SELECT TARIFA " + 
				"FROM CONFIGURACOES " +
				"WHERE ID = 0;";
				
			var tarifaObtida:String;
			
			var r:SQLResult;			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterTarifa;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterTarifa);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterTarifaErro);
			stmt.execute();
								
			return tarifaObtida;
									
			function tratadoraObterTarifa(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					tarifaObtida = r.data[0].TARIFA.toString();
				}
			}
			
			function tratadoraObterTarifaErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao pesquisar por tarifa: " + event.error.details);
			}
		}
		
		public static function setTarifa(tarifa:String):Boolean
		{
			var comandoObterTarifa:String =
				"UPDATE CONFIGURACOES " + 
				"SET TARIFA = " + tarifa + " "
				"WHERE ID = 0;";

			var tarifaObtida:String;
			
			var r:SQLResult;			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterTarifa;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterTarifa);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterTarifaErro);
			
			var sucesso:Boolean = true;
			
			stmt.execute();
			return sucesso;
								
									
			function tratadoraObterTarifa(event:SQLEvent):void
			{
				/*r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					tarifaObtida = r.data[0].TARIFA.toString();
				}*/
			}
			
			function tratadoraObterTarifaErro(event:SQLErrorEvent):void
			{
				sucesso = false;
				Alert.show("Erro ao mudar tarifa: " + event.error.details);
			}
		}
		
		public static function getVersao():String
		{
			var comandoObterTarifa:String =
				"SELECT VERSAO " + 
				"FROM CONFIGURACOES " +
				"WHERE ID = 0;";
				
			var versaoObtida:String;
			
			var r:SQLResult;			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoObterTarifa;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraObterTarifa);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraObterTarifaErro);
			stmt.execute();
								
			return versaoObtida;
									
			function tratadoraObterTarifa(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					versaoObtida = r.data[0].TARIFA.toString();
				}
			}
			
			function tratadoraObterTarifaErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao pesquisar por tarifa: " + event.error.details);
			}
		}
	}
}