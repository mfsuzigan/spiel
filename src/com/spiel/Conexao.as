package com.spiel
{
	import flash.data.SQLConnection;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	public class Conexao extends SQLConnection
	{
		private static var conexao:Conexao;
		
		public static function get():Conexao{
			
			if (conexao == null){
				var novaConexao:Conexao = new Conexao();
				var arquivo:File = File.applicationDirectory.resolvePath("resources\\database\\spiel.db");
				//Alert.show(arquivo.nativePath);
				novaConexao.addEventListener(SQLEvent.OPEN, tratadoraOpen);
				novaConexao.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);	
				novaConexao.open(arquivo, "update");
				
				conexao = novaConexao;
				
			}/* else if (!conexao.connected){
				conexao.open(arquivo, "update");
			}*/
			
			return conexao;
		}
		
		
		private static function tratadoraOpen(event:SQLEvent):void
		{
			//Alert.show("Conexão aberta com sucesso.");
		}
		
		private static function tratadoraErro(event:SQLErrorEvent):void
		{
			Alert.show("Erro ao abrir conexão: " + event.error.details);
		}
	}
}