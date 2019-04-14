package com.spiel
{
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import mx.controls.Alert;
	
	public class DespesaFixa
	{
		[Bindable]
		public var id:Number;
		
		[Bindable]
		public var nome:String;
		
		[Bindable]
		public var valor:Number;
		
		public function DespesaFixa()
		{
			super();
		}
		
		public function getId():Number {
			return id;
		}
			
		public function setId(id:Number):void{
			this.id = id;
		}
		
		public function getNome():String{
			return nome;
		}
		
		public function setNome(nome:String):void{
			this.nome = nome;
		}
		
		public function getValor():Number{
			return valor;
		}
		
		public function setValor(valor:Number):void{
			this.valor = valor;
		}
		
		
		public function inserir():Boolean {
			var sucesso:Boolean = false;
						
			var comandoInserir:String =
				"INSERT " + 
				"INTO DESPESAS_FIXAS (NOME, VALOR) " +
				"VALUES ('" + nome + "', " + valor + ");";
				
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
				Alert.show("Erro ao inserir despesa no sistema: " + event.error.details);
			}
			
			return sucesso;
		}
			
		public function remover():Boolean
		{				
			var comandoRemover:String =			
				"DELETE FROM DESPESAS_FIXAS " +
				"WHERE NOME = '" + nome + "'; ";
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoRemover;
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraRemoverErro);
			stmt.execute();
			
			function tratadoraRemoverErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao remover despesa: " + event.error.details);
			}
			
			return true;
		}
		
		public function recuperar():void {
			var comandoRecuperar:String =
				"SELECT * " + 
				"FROM DESPESAS_FIXAS " +
				"WHERE NOME = '" + getNome() + "' ";				
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoRecuperar;
			stmt.addEventListener(SQLEvent.RESULT, tratadora);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			stmt.execute();
			var r:SQLResult;
		
			function tratadora(event:SQLEvent):void
			{
				r = stmt.getResult();
			
				if (r is Object && r.data is Object)
				{
					setId(Number(r.data[0].ID.toString()));
					setNome(r.data[0].NOME.toString());
					setValor(Number(r.data[0].VALOR.toString()));	
				}
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao recuperar despesa no sistema: " + event.error.details);
			}
		}
			
		public function atualizar():Boolean {
			var foiExecutadoComSucesso:Boolean = false;

			var comandoAtualizar:String =
				"UPDATE " + 
				"DESPESAS_FIXAS " +
				"SET NOME = '" + nome + "', VALOR = '" + valor + "' " +
				"WHERE ID = " + id + " ";				
				
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = Conexao.get();
			stmt.text = comandoAtualizar;
			stmt.addEventListener(SQLEvent.RESULT, tratadora);
			stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
			stmt.execute();
		
			function tratadora(event:SQLEvent):void
			{
				foiExecutadoComSucesso = true;
			}
			
			function tratadoraErro(event:SQLErrorEvent):void
			{
				Alert.show("Erro ao atualizar despesa no sistema: " + event.error.details);
			}
			
			return foiExecutadoComSucesso;
		}
			
		public static function valorTemValidade(valor:String):Boolean {
			var valorTemValidade:Boolean = false;
			
			if (Utils.stringIsBlank(valor)){
				Alert.show("Valor da despesa inválido");
								
			} else {
				valorTemValidade = true;
			}
			
			return valorTemValidade;
		}
		
			
		public static function nomeTemValidade(nome:String):Boolean {
			var nomeTemValidade:Boolean = false;
			
			if (Utils.stringIsBlank(nome)){
				Alert.show("Nome da despesa inválido");
								
			} else if (existeDespesaComONome(nome)){
				Alert.show("Já existe uma despesa com este nome");
				
			} else {
				nomeTemValidade = true;
			}
			
			return nomeTemValidade;
		}
	
	public function obterTodasAsDespesas():Array{
		var comandoRecuperar:String = "" +
						"SELECT * " +
						"FROM DESPESAS_FIXAS;";
		
		var s:SQLStatement = new SQLStatement();	
		s.text = comandoRecuperar;
		s.sqlConnection = Conexao.get();
		s.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
		s.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
		var despesas:Array = new Array();
		var r:SQLResult;
		
		try {
			s.execute();
		}
		
		catch (erro:Error) {
			Alert.show("Erro ao recuperar despesas: " + erro.message);
		}
		
		return despesas;
		
		function tratadoraRecuperar(event:SQLEvent):void
		{
			r = s.getResult();
			
			if (r is Object && r.data is Object)
			{
				for (var i:Number = 0; i < r.data.length; i++)
				{
					var despesa:DespesaFixa = new DespesaFixa();
					despesa.setId(Number(r.data[i].ID.toString()));
					despesa.setNome(r.data[i].NOME.toString());
					despesa.setValor(Number(r.data[i].VALOR.toString()));	
					despesas.push(despesa);
				}
			}
		}
		
		function tratadoraRecuperarErro(event:SQLErrorEvent):void {
			Alert.show("Erro ao recuperar despesas: " + event.error.details);	
		}
	}
		
	public static function existeDespesaComONome(nomeDespesa:String):Boolean {
		
		var comandoRecuperar:String = "" +
						"SELECT 1 " +
						"FROM DESPESAS_FIXAS WHERE NOME = '" + nomeDespesa + "';";
		
		var s:SQLStatement = new SQLStatement();	
		s.text = comandoRecuperar;
		s.sqlConnection = Conexao.get();
		s.addEventListener(SQLEvent.RESULT, tratadoraRecuperar);
		s.addEventListener(SQLErrorEvent.ERROR, tratadoraRecuperarErro);
		var existeDespesa:Boolean = false;
		
		try {
			s.execute();
		}
		
		catch (erro:Error) {
			Alert.show("Erro ao recuperar despesa pelo nome: " + erro.message);
		}
		
		return existeDespesa;
		
		function tratadoraRecuperar(event:SQLEvent):void {
			var r:SQLResult = s.getResult();
			
			existeDespesa = (r is Object && r.data is Object);
		}
		
		function tratadoraRecuperarErro(event:SQLErrorEvent):void {
			Alert.show("Erro ao recuperar despesa pelo nome: " + event.error.details);	
		}
	}
	}
}