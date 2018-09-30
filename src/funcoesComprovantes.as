// ActionScript file

import com.spiel.Conexao;

import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.validators.RegExpValidator;

public function tratarChangeEventPlacaComprovante(event:Event):void
{
	abrirSugestoesComprovante(inputPlacaComprovante, 'MOVIMENTACOES', 'PLACA', sugestoesPlacaComprovante);
	formatarTextoPlacaComprovante();
	
	
	if (inputPlacaComprovante.text == "" || !isInputPlacaComprovanteValido(event))
	{
		povoarTabelaComprovantesImpressos(null);	
	}
	
	else
	{
		povoarTabelaComprovantesImpressos(inputPlacaComprovante.text);		
	}
}
			
public function formatarTextoPlacaComprovante():void
{
	// Formata o texto entrado no campo de texto principal
	
	inputPlacaComprovante.text = inputPlacaComprovante.text.toUpperCase();
		
	var expColocarEspaco:RegExp = /^[A-Z]{3}$/;
	
	if (expColocarEspaco.test(inputPlacaComprovante.text) && inputPlacaLength == 2)
	{
		inputPlacaComprovante.text = inputPlacaComprovante.text.substr(0, 3) + " " + inputPlacaComprovante.text.substr(3, 1);
		inputPlacaComprovante.setSelection(5, 5);
	}
	
	inputPlacaLength = inputPlacaComprovante.text.length;
}

public function abrirSugestoesComprovante(textInput:TextInput, tabela:String, coluna:String, sugestoes:List):void
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
					
	var app:TelaTransito = this;
	
	if (!app.hasEventListener(MouseEvent.CLICK))
	{
		app.addEventListener(MouseEvent.CLICK, tratarClique);
		app.addEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	}
	
	var outputSugestoes:Array = new Array();
	var r:SQLResult;
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();
	
	
	stmt.text = "" +
		"SELECT DISTINCT " + coluna + " " + 
		"FROM " + tabela + " " +
		"WHERE " + coluna + " LIKE '" + textInput.text + "%' " + 
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
			//tabelaComprovante.povoar(textInput.text, null, null);
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

public function forcarSugestaoComprovante(textInput:TextInput, sugestoes:List, event:FocusEvent):void
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

public function isInputPlacaComprovanteValido(event:Event):Boolean
{	
	var validador:RegExpValidator = new RegExpValidator();
	validador.noMatchError = "Placa inválida";
	validador.source = inputPlacaComprovante;
	validador.required = false;
	validador.property = "text";
	validador.expression = "^[A-Z]{3} [0-9]{4}$";
	return (validador.validate().type == ValidationResultEvent.VALID);
}