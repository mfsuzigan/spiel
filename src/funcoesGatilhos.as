// ActionScript file
// ActionScript file

import com.spiel.Anotacao;
import com.spiel.Conexao;
import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.List;
import mx.controls.TextInput;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.validators.RegExpValidator;


[Bindable]
public var inputPlacaLength:Number = 0;

[Bindable]
public var isAlvoPlaca:Boolean;

[Bindable]
public var confirmarSalvamento:Boolean

public function toggleCheckboxPlaca():void
{
	if (!checkboxGatilhoPlaca.selected)
	{
		inputGatilhoPlaca.text = "";
		inputGatilhoPlaca.enabled = false;
		checkboxGatilhoIdMovimentacao.enabled = true;		
		
		//botaoSalvarGatilho.enabled = (checkboxGatilhoIdMovimentacao.selected);
	}
	
	else
	{
		inputGatilhoIdMovimentacao.text = "";
		inputGatilhoIdMovimentacao.enabled = false;
		
		inputGatilhoPlaca.enabled = true;
		checkboxGatilhoIdMovimentacao.selected = false;
		checkboxGatilhoIdMovimentacao.enabled = false;
		
		//botaoSalvarGatilho.enabled = true;
	}
}

public function toggleCheckboxIdMovimentacao():void
{
	if (!checkboxGatilhoIdMovimentacao.selected)
	{
		inputGatilhoIdMovimentacao.text = "";
		inputGatilhoIdMovimentacao.enabled = false;
		checkboxGatilhoPlaca.enabled = true;
		
		//botaoSalvarGatilho.enabled = (checkboxGatilhoPlaca.selected);
	}
	
	else
	{
		inputGatilhoPlaca.text = "";
		inputGatilhoPlaca.enabled = false;
		
		inputGatilhoIdMovimentacao.enabled = true;		
		checkboxGatilhoPlaca.selected = false;
		checkboxGatilhoPlaca.enabled = false
		//botaoSalvarGatilho.enabled = true;
	}
}

public function formatarTextoPlacaGatilho():void
{
	// Formata o texto entrado no campo de texto principal
	
	inputGatilhoPlaca.text = inputGatilhoPlaca.text.toUpperCase();
		
	var expColocarEspaco:RegExp = /^[A-Z]{3}$/;
	
	if (expColocarEspaco.test(inputGatilhoPlaca.text) && inputPlacaLength == 2)
	{
		inputGatilhoPlaca.text = inputGatilhoPlaca.text.substr(0, 3) + " " + inputGatilhoPlaca.text.substr(3, 1);
		inputGatilhoPlaca.setSelection(5, 5);
	}
	
	inputPlacaLength = inputGatilhoPlaca.text.length;
	
	//processarInput();	
}

public function salvarGatilho():void
{
	if (!confirmarSalvamento)
	 
	 	return;
	
	//Gatilhos para uma anotação já existente:
	if (Application.application.indiceAnotacaoSelecionada != -1)
	{ 	
		var anotacao:Anotacao = new Anotacao(true, null, null, null, null);
		var anotacaoSelecionada:Object = Application.application.anotacaoSelecionada;
		var tAnotacaoSelecionada:String = Utils.getStringInstanteDH(anotacaoSelecionada.dia.toString(), anotacaoSelecionada.hora.toString());
		 
		anotacao.obterDados(tAnotacaoSelecionada);
		
		if (isAlvoPlaca)
		{
			anotacao.setPlacaAssociada(inputGatilhoPlaca.text);
			anotacao.setIdMovimentacaoAssociada("-1");
		}
		
		else
		{
			anotacao.setIdMovimentacaoAssociada((inputGatilhoIdMovimentacao.text == "") ? "-1" : inputGatilhoIdMovimentacao.text);
			anotacao.setPlacaAssociada("");
		}
		
		Application.application.atualizacaoGatilho = anotacao.flush();
	}
	
	// Gatilhos para uma anotação nova
	else
	{
		if (isAlvoPlaca)
		
			Application.application.placaGatilhoAnotacaoNova = inputGatilhoPlaca.text;
			
		else
		
			Application.application.idMovimentacaoGatilhoAnotacaoNova = inputGatilhoIdMovimentacao.text;
	}
	
	Application.application.painelGatilhos.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
}

public function resolverInputGatilho(input:TextInput):void
{
	isAlvoPlaca = (input.id == "inputGatilhoPlaca");
	
	if (!isAlvoPlaca)
	{
		abrirSugestoesGatilhos(input, "MOVIMENTACOES", "ID", sugestoesIdMovimentacao);
	}
		
	else
	{
		formatarTextoPlacaGatilho();
		abrirSugestoesGatilhos(input, "VEICULOS", "PLACA", sugestoesPlaca);
	}	
}

public function povoarCampos():void
{
	if (Application.application.indiceAnotacaoSelecionada != -1)
	{
		if (Application.application.anotacaoSelecionada.placa.toString() != "-")
		{
			checkboxGatilhoPlaca.selected = true;
			inputGatilhoPlaca.enabled = true;
			inputGatilhoPlaca.text = Application.application.anotacaoSelecionada.placa.toString();
		}
		
		else if (Application.application.anotacaoSelecionada.codigoDeEntrada.toString() != "-")
		{
			checkboxGatilhoIdMovimentacao.selected = true;
			inputGatilhoIdMovimentacao.enabled = true;
			inputGatilhoIdMovimentacao.text = Application.application.anotacaoSelecionada.codigoDeEntrada.toString();
		}
		
		botaoSalvarGatilho.enabled = true;
	}
	
	else
	{
		checkboxGatilhoPlaca.selected = false;
		inputGatilhoPlaca.enabled = false;
		inputGatilhoPlaca.text = "";
		
		checkboxGatilhoIdMovimentacao.selected = false;
		inputGatilhoIdMovimentacao.enabled = false;
		inputGatilhoIdMovimentacao.text = "";
		
		botaoSalvarGatilho.enabled = false;
	}
}

////////////// Funções para sugestão dos campos de placa e código de entrada


public function abrirSugestoesGatilhos(textInput:TextInput, tabela:String, coluna:String, sugestoes:List):void
{	
	// Dada uma List "sugestoes", sugere strings baseada no que é digitado
	// num textInput. Recebe como argumentos uma referência para o TextInput, 
	// o nome da tabela e o nome da coluna de onde deve ser feita a captura das 
	// sugestões.
		
	if 	(		textInput.text == "" 
		)
	{
		sugestoes.visible = false;
		return;
	}
	
	if (!sugestoes.hasEventListener(ListEvent.ITEM_CLICK))
	{
		sugestoes.addEventListener(ListEvent.ITEM_CLICK, capturarSugestao);
		sugestoes.addEventListener(KeyboardEvent.KEY_DOWN, capturarSugestao);
	}
	
	textInput.addEventListener(KeyboardEvent.KEY_DOWN, rolarSugestoes);
					
	var app:PainelGatilhosAnotacoes = this;				
	app.addEventListener(MouseEvent.CLICK, tratarClique);
	app.addEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	
	var outputSugestoes:Array = new Array();
	var r:SQLResult;
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();
	
	
	stmt.text = "" +
		"SELECT " + coluna + ((tabela == "MOVIMENTACOES" && coluna == "ID") ? ", PLACA AS P " : " ") + 
		"FROM " + tabela + " " +
		"WHERE " + coluna + " LIKE '" + textInput.text + "%' " + 
		(	(tabela == "MOVIMENTACOES" && coluna == "ID") 
			?  "AND T IN (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) AND CODIGO = 1 "
			: ""
		) +
		"ORDER BY " + coluna + ";";
			
	stmt.addEventListener(SQLEvent.RESULT, tratadoraAbrirSugestoes);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraAbrirSugestoesErro);
	stmt.execute();
	stmt.sqlConnection.close();
							
	if (outputSugestoes.length == 1)
	{
		sugestoes.height = 22.5;
	}
		
	else
	{
		sugestoes.height = 48;
	}
						
	function tratadoraAbrirSugestoes(event:SQLEvent):void
	{
		// Responsável por povoar a List e exibi-la.
		
		r = stmt.getResult();					
		
		if (r.data is Object)
		{	
			outputSugestoes = new Array();
			
			for (var i:int = 0; i < r.data.length; i++)
		  	{
		    	outputSugestoes.push(r.data[i][coluna]);
		    }
		   
		    sugestoes.dataProvider = outputSugestoes;
		    sugestoes.visible = !(outputSugestoes.length == 1 && outputSugestoes[0].toString() == textInput.text);					    		    		
		}
		
		else
		{
			sugestoes.visible = false;
			return;
		}
	}
	
	function tratadoraAbrirSugestoesErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao sugerir resultados para a caixa de texto: " + event.text);
	}
									
	function fecharSugestoes(event:Event):void
	{
		// Fecha a lista, adequando seu índice e o cursor, além de
		// lidar com event listeners que não são mais necessários.
		
		//Alert.show("fecharSugestoes()");
		
		sugestoes.visible = false;
		app.removeEventListener(MouseEvent.CLICK, tratarClique);
		app.removeEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
		sugestoes.removeEventListener(ListEvent.ITEM_CLICK, capturarSugestao);
		sugestoes.removeEventListener(KeyboardEvent.KEY_DOWN, capturarSugestao);
		sugestoes.selectedIndex= -1;
		textInput.setFocus();
		textInput.setSelection(textInput.text.length, textInput.text.length);
	}
	
	function capturarSugestao(event:Event):void
	{
		
		// Captura um clique de mouse ou teclada sobre a List
		// e exibe o resultado no textInput
		// Uma teclada com a seta direta volta o foco sobre
		// o textInput
		
		if (event is KeyboardEvent)
		{
			if ((KeyboardEvent)(event).keyCode == Keyboard.RIGHT)
			{
				fecharSugestoes(event);
			}
			
			else if ((KeyboardEvent)(event).keyCode == Keyboard.ENTER)
			{//Alert.show('==Keyboard.Enter');
				//rolarSugestoes(event);
			}
			
			else if ((KeyboardEvent)(event).keyCode == Keyboard.BACKSPACE)
			{
				textInput.text = textInput.text.substr(0, textInput.text.length - 2);
				fecharSugestoes(event);
				return;
			}
			
			else
			{
				return;
			}
		}
		
		try
		{
			textInput.text = event.currentTarget.selectedItem.toString();
			textInput.dispatchEvent(new Event(Event.CHANGE));
		}
		
		catch (e:Error)
		{
		}
		
		fecharSugestoes(event);		
	}
	
	function tratarClique(event:MouseEvent):void
	{				
		if 	(		!sugestoes.contains((DisplayObject)(event.target)) 
				&& 	!textInput.contains((DisplayObject)(event.target))
			)
		
			fecharSugestoes(event);
	}
	
	function tratarTeclada(event:KeyboardEvent):void
	{
		if (event.charCode == Keyboard.TAB)
		{
			fecharSugestoes(event);
		}
	}
	
	function rolarSugestoes(event:KeyboardEvent):void
	{
		if (!sugestoes.visible || event.keyCode != Keyboard.DOWN)
		{//Alert.show('1');
			//fecharSugestoes(event);
			return;
		}
		
		if (event.keyCode == Keyboard.DOWN)
		{//Alert.show('2');
			sugestoes.setFocus();
			sugestoes.selectedIndex = 0;
		}
		
		textInput.removeEventListener(KeyboardEvent.KEY_DOWN, rolarSugestoes);
	}
}

public function forcarSugestaoGatilhos(textInput:TextInput, sugestoes:List, event:FocusEvent):void
{
	if (event.relatedObject == sugestoes)
	
		return;
	
	if 	(		textInput.text != "" 
			&&	sugestoes.dataProvider is Object 
			&& (ArrayCollection)(sugestoes.dataProvider).length == 1
		)
	{
		try
		{
			textInput.text = (Array)(sugestoes.dataProvider).pop().toString();
			
		}
		
		catch (e:Error)
		{
		}
	}
	
	sugestoes.visible = false;
}

public function validarInputGatilho(event:Event):void
{	
	var validador:RegExpValidator = new RegExpValidator();
	validador.noMatchError = (isAlvoPlaca) ? "Placa inválida" : "Código de entrada inválido";
	validador.source = (isAlvoPlaca) ? inputGatilhoPlaca : inputGatilhoIdMovimentacao;
	validador.required = false;
	validador.property = "text";
	validador.expression = (isAlvoPlaca) ? "^[A-Z]{3} [0-9]{4}$" : "^[0-9]*$";
	var resultadoValidacao:ValidationResultEvent = validador.validate();
	
	if 	(	(isAlvoPlaca && inputGatilhoPlaca.text != "")
		||	(!isAlvoPlaca && inputGatilhoIdMovimentacao.text != "")
		)
	{
		botaoSalvarGatilho.enabled = (resultadoValidacao.type == ValidationResultEvent.VALID);	
		
	}
}

public function confirmarSalvamentoGatilho():void
{
	var veiculo:Veiculo = new Veiculo();
	var confirmacao:Boolean;
	
	if (isAlvoPlaca && !veiculo.obterDados(inputGatilhoPlaca.text) && inputGatilhoPlaca.text != "")
	{
		Alert.show("A placa inserida corresponde a um veículo que ainda não foi registrado. Tem certeza que deseja associar a anotação a tal veículo?", "Atenção", Alert.YES|Alert.NO, null, funcaoHandler);
	}
	 
	else if (!isAlvoPlaca && !Movimentacao.existeEntrada(inputGatilhoIdMovimentacao.text) && inputGatilhoIdMovimentacao.text != "")
	{
	 	Alert.show("O código de entrada inserido corresponde a uma movimentação não existente. Tem certeza que deseja associar a anotação a tal código?", "Atenção", Alert.YES|Alert.NO, null, funcaoHandler);
	}
	
	else
	{
		confirmarSalvamento = true;
		salvarGatilho();
	}
	 
	function funcaoHandler(event:CloseEvent):void
	{
		confirmarSalvamento = (event.detail == Alert.YES);
		salvarGatilho();
	}
}