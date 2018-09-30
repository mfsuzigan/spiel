package com.spiel
{
	import flash.data.SQLConnection;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	public class Conexao extends SQLConnection
	{
		public function Conexao()
		{
			super();
			
			var arquivo:File = File.applicationDirectory.resolvePath("resources\\database\\spiel.db");
			//Alert.show(arquivo.nativePath);
			this.addEventListener(SQLEvent.OPEN, tratadoraOpen);
			this.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);			
			this.open(arquivo, "update");
		}
		
		private function tratadoraOpen(event:SQLEvent):void
		{
			//Alert.show("Conexão aberta com sucesso.");
		}
		
		private function tratadoraErro(event:SQLErrorEvent):void
		{
			Alert.show("Erro ao abrir conexão: " + event.error.details);
		}
	}
}