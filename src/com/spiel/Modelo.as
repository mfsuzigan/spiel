
package com.spiel
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	
	public class Modelo
	{
		private var nome:String;
		private var idMarca:String;
		private var id:String;
		
		public function Modelo(construtorPadrao:Boolean, nome:String, idMarca:String)
		{
			if (!construtorPadrao)
			{
				this.nome = nome;
				this.idMarca = idMarca;
			}
		}
		
		public function obterDados(nome:String):Boolean
		{
			var sucesso:Boolean = false;			
			var idObtido:String;
			var idMarca:String;
									
			var comandoRecuperar:String =
				"SELECT ID, ID_MARCA " + 
				"FROM MODELOS " +
				"WHERE NOME = '" + nome + "';";
				
			var r:SQLResult;
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = new Conexao();
			stmt.text = comandoRecuperar;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			
			stmt.execute();
			
			if (r is Object && r.data is Object)
			{
				this.id = idObtido;
				this.nome = nome;
				this.idMarca = idMarca;
			}
			
			return sucesso;

			function tratadoraRecuperar(event:SQLEvent):void
			{
				r = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					idObtido = r.data[0].ID.toString();
					idMarca = r.data[0].ID_MARCA.toString();
					sucesso = true;
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao obter dados de modelo de veículo: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public function registrar():Boolean
		{
			var sucesso:Boolean = false;
									
			var comandoInserir:String =
				"INSERT " + 
				"INTO MODELOS (NOME, ID_MARCA) " +
				"VALUES ('" + this.nome + "', " + this.idMarca  + ");";
				
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
				Alert.show("Erro ao inserir modelo de veículo no sistema: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public function atualizar():Boolean
		{
			var sucesso:Boolean = false;
									
			var comandoInserir:String =
				"UPDATE MODELOS " + 
				"SET NOME = '" + this.nome + "', ID_MARCA = " + this.idMarca + " " + 
				"where ID = " + this.id;
				
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
				Alert.show("Erro ao atualizar modelo de veículo no sistema: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public static function getNomesModelos():Array
		{
			var nomesDeModelos:Array = new Array();
									
			var comandoRecuperar:String = "" +
				"SELECT NOME " +
				"FROM MODELOS ORDER BY NOME;";

			var s:SQLStatement = new SQLStatement();
			s.text = comandoRecuperar;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);

			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar levantar nomes de modelos de veículos: " + erro.message);
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
							nomesDeModelos.push(r.data[i].NOME.toString());							
						}
					}					
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar levantar nomes de modelos de veículos: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar nomes de modelos de veículos: " + event.error.details);	
			}

			return nomesDeModelos;
		}
		
		public static function getNomesModelosDeMarca(idMarca:String):Array
		{
			var nomesDeModelos:Array = new Array();
									
			var comandoRecuperar:String = "" +
				"SELECT NOME " +
				"FROM MODELOS WHERE ID_MARCA = " + idMarca + " order by nome;";

			var s:SQLStatement = new SQLStatement();	
			s.text = comandoRecuperar;
			s.sqlConnection = new Conexao();
			s.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);

			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar levantar nomes de modelos de veículos: " + erro.message);
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
							nomesDeModelos.push(r.data[i].NOME.toString());							
						}
					}					
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar levantar nomes de modelos de veículos: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar nomes de modelos de veículos: " + event.error.details);	
			}

			return nomesDeModelos;
		}
		
		public function getId():String
		{
			return this.id;
		}
		
		public function getIdMarca():String
		{
			return this.idMarca;
		}
		
		public function setNome(nome:String):void
		{
			this.nome = nome;
		}
		
		public function setIdMarca(idMarca:String):void
		{			
			this.idMarca = idMarca;			
		}
		
		public function flush():Boolean
		{			
			var sucesso:Boolean = false;
			var comandoFlush:String =
				"UPDATE MODELOS " + 
				"SET 	ID_MARCA = " + this.idMarca + ", " + 
						"NOME = '" + this.nome + "' " +
				"WHERE ID = '" + this.id + "';";
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.text = comandoFlush;
			stmt.sqlConnection = new Conexao();
			stmt.addEventListener(SQLEvent.RESULT, tratadoraFlush);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraFlushErro);
			stmt.execute();
			stmt.sqlConnection.close();
			
			return sucesso;

			function tratadoraFlush(event:SQLEvent):void
			{
				sucesso = true;
			}
			
			function tratadoraFlushErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar modelo veículo: " + event.error.details);
			}
		}
	}
}