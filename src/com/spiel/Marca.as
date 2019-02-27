package com.spiel
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	
	public class Marca
	{
		private var nome:String;
		private var id:String;
		
		public function Marca(construtorPadrao:Boolean, nome:String)
		{
			if (!construtorPadrao)
			{
				this.nome = nome;
			}
		}
		
		public function getId():String
		{
			return this.id;
		}
		
		public function getNome():String
		{
			return this.nome;
		}
		
		public function obterDados(nome:String):Boolean
		{
			var sucesso:Boolean = false;
						
			this.nome = nome;
			
			var comandoRecuperar:String =
				"SELECT * " + 
				"FROM MARCAS " +
				"WHERE NOME = '" + nome + "';";
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoRecuperar;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			stmt.execute();
			
			var idObtido:String;
			this.id = idObtido;
			return sucesso;

			function tratadoraRecuperar(event:SQLEvent):void
			{
				var r:SQLResult = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					idObtido = r.data[0].ID.toString();
					sucesso = true;
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao obter dados de marca de veículo: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public function obterDadosPorId(id:String):Boolean
		{
			var sucesso:Boolean = false;
						
			this.id = id;
			
			var comandoRecuperar:String =
				"SELECT * " + 
				"FROM MARCAS " +
				"WHERE ID = '" + id + "';";
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoRecuperar;
			stmt.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			stmt.execute();
			
			var nomeObtido:String;
			this.nome = nomeObtido;
			return sucesso;

			function tratadoraRecuperar(event:SQLEvent):void
			{
				var r:SQLResult = stmt.getResult();
				
				if (r is Object && r.data is Object)
				{
					nomeObtido = r.data[0].NOME.toString();
					
					sucesso = true;
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao obter dados de marca de veículo: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public function registrar():Boolean
		{
			var sucesso:Boolean = false;
						
			var comandoInserir:String =
				"INSERT " + 
				"INTO MARCAS (NOME) " +
				"VALUES ('" + this.nome + "');";
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
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
				Alert.show("Erro ao inserir marca de veículo no sistema: " + event.error.details);
			}
			
			return sucesso;
		}
		
		public static function getNomesMarcas():Array
		{
			var nomesDeMarcas:Array = new Array();
									
			var comandoRecuperar:String = "" +
				"SELECT NOME " +
				"FROM MARCAS ORDER BY NOME;";

			var s:SQLStatement = new SQLStatement();	
			s.text = comandoRecuperar;
			s.sqlConnection = Conexao.get();
			s.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
			
			
			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar levantar nomes de marcas de veículos: " + erro.message);
			}
			
			function tratadoraRecuperar(event:SQLEvent):void
			{
				var r:SQLResult = s.getResult();
				
				try
				{	
					if (r is Object && r.data is Object)
					{
						for (var i:Number = 0; i < r.data.length; i++)
						{
							nomesDeMarcas.push(r.data[i].NOME.toString());							
						}
					}					
				}
				
				catch (erro:Error)
				{
					Alert.show("Erro ao tentar levantar nomes de marcas de veículos: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar nomes de marcas de veículos: " + event.error.details);	
			}

			return nomesDeMarcas;
		}
		
		public function getNomesModelos():Array
		{
			var nomesDeModelos:Array = new Array();
									
			var comandoRecuperar:String = "" +
				"SELECT MODELOS.NOME as NOME " +
				"FROM MODELOS " + 
				"WHERE MODELOS.ID_MARCA = " + this.id + " order by NOME;"

			var s:SQLStatement = new SQLStatement();	
			s.text = comandoRecuperar;
			s.sqlConnection = Conexao.get();
			s.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
			s.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);

			try 
			{
				s.execute();
			}
			
			catch (erro:Error)
			{
				Alert.show("Erro ao tentar levantar modelos de marca de veículo: " + erro.message);
			}
			
			
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
					Alert.show("Erro ao tentar levantar modelos de marca de veículo: " + erro.getStackTrace());
				}
			}
			
			function tratadoraRecuperarErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao levantar nomes de marcas de veículos: " + event.error.details);	
			}

			return nomesDeModelos;
		}
	}
}