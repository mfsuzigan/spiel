// ActionScript file

import com.spiel.Conexao;
import com.spiel.Configuracoes;

import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;

import mx.containers.TitleWindow;
import mx.controls.Alert;
import mx.controls.TextInput;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.ValidationResultEvent;
import mx.validators.RegExpValidator;

[Bindable]
public var validador:RegExpValidator = new RegExpValidator();

public function validarSenhaEntrada(senhaEntrada:String, inputSenha:TextInput, janela:TitleWindow):void
{
	validador.noMatchError = "Senha incorreta";
	validador.requiredFieldError = "Senha incorreta";
	validador.source = inputSenha;
	validador.required = true;
	validador.property = "text";
	validador.expression = "[a-zA-Z0-9\s_]+";
	var resultadoValidacao:ValidationResultEvent = validador.validate();
	
	if (resultadoValidacao.type == ValidationResultEvent.INVALID)
		return;
	
	if 	(!autorizacao(senhaEntrada))
	{
		validador.expression = "!";
		validador.validate();
		return;	
	}
	
	janela.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
	
	switch (this.escopo)
	{
		case "desfazer":
			Application.application.telaTransito.mostrarJanelaDesfazer();
			break;
			
		case "tarifa":
			if (Configuracoes.setTarifa(Application.application.telaConfiguracoes.inputTarifa.text))
			{
				Alert.show("Tarifa alterada com sucesso", "Tarifa alterada");
				Application.application.telaConfiguracoes.atualizarTarifa();
			}
			break;
			
		case "apagarVeiculo":
			Application.application.telaBusca.trataCliqueBotaoApagar();
			break;
			
		case "agregarInformacoes":
			Application.application.telaConfiguracoes.confirmarAgregarDadosDeBD();
			break;
			
		case "limparHistorico":
			Application.application.telaConfiguracoes.confirmarLimparHistorico();
			break;
	}
}

public function autorizacao(senha:String):Boolean
{

	var autorizar:Boolean = false;
	var r:SQLResult;
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();
	
	stmt.text = "" +
		"SELECT SENHA " + 
		"FROM CONFIGURACOES;";
			
	stmt.addEventListener(SQLEvent.RESULT, tratadoraAutorizacao);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraAutorizacaoErro);
	stmt.execute();
	stmt.sqlConnection.close();
	
	return autorizar;
					
	function tratadoraAutorizacao(event:SQLEvent):void
	{
		r = stmt.getResult();
		
		autorizar = r.data is Object && r.data[0].SENHA.toString() == senha;					
	}
	
	function tratadoraAutorizacaoErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao recuperar senha do banco de dados: " + event.text);
	}
}
