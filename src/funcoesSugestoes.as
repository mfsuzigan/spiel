import com.spiel.Conexao;
import com.spiel.Cor;
import com.spiel.Modelo;
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
import mx.events.ListEvent;



public function abrirSugestoes(textInput:TextInput, tabela:String, coluna:String, sugestoes:List):void
{	
	// Dada uma List "sugestoes", sugere strings baseada no que é digitado
	// num textInput. Recebe como argumentos uma referência para o TextInput, 
	// o nome da tabela e o nome da coluna de onde deve ser feita a captura das 
	// sugestões.
		
	if 	(		textInput.text == "" 
			||	!Utils.validarInput(textInput)
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
	app.addEventListener(MouseEvent.CLICK, tratarClique);
	app.addEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	
	// procurando placas de veículos?
	var queryPlacas:Boolean = (tabela == "VEICULOS" && coluna == "PLACA");
	
	//procurando ids de movimentações?
	var queryIdsMovimentacoes:Boolean = (tabela == "MOVIMENTACOES" && coluna == "ID");
	
	// a saída:
	var outputSugestoes:Array = new Array();
	
	// para os resultados de queries "regulares":
	var r:SQLResult;	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = Conexao.get();
	
	// para sugestoes de placas de veículos não registrados:
	
	var stmtSugestoes:SQLStatement;
	var rSugestoes:SQLResult;
		
	stmt.text = "" +
		"SELECT " + coluna + (queryIdsMovimentacoes ? ", PLACA AS P " : " ") +
		"FROM " + tabela + " " +
		"WHERE " + coluna + " LIKE '" + textInput.text + "%' " + 
		(	queryIdsMovimentacoes 
			?  "AND T IN (SELECT MAX(T) FROM MOVIMENTACOES WHERE PLACA = P) AND CODIGO = 1 "
			: ""
		) +
		"ORDER BY " + coluna + ";";
		
	//Alert.show(stmt.text);
			
	stmt.addEventListener(SQLEvent.RESULT, tratadoraAbrirSugestoes);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraAbrirSugestoesErro);
	
	// execução de query para sugestoes de placas de veículos não registrados:	
	if (queryPlacas)
	{
		stmtSugestoes = new SQLStatement();
				
		stmtSugestoes.text = "" +
		"SELECT PLACA " +
		"FROM SUGESTOES " +
		"WHERE PLACA LIKE '" + textInput.text + "%' " + 
		"ORDER BY PLACA;"
		
		stmtSugestoes.sqlConnection = Conexao.get();
		stmtSugestoes.addEventListener(SQLEvent.RESULT, fInterna);
		stmtSugestoes.execute();
		
		function fInterna(event:SQLEvent):void
		{
			rSugestoes = stmtSugestoes.getResult();
		}
	}
	
	stmt.execute();
							
	if (outputSugestoes.length <= 4)
	{
		sugestoes.height = 22.5 * outputSugestoes.length;
	}
		
	else if (outputSugestoes.length > 4)
	{
		sugestoes.height = 88;
	}
	
	if (textInput == inputModelo || textInput == inputCor)
	{
		app.removeEventListener(MouseEvent.CLICK, tratarClique);
		//app.removeEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	}
						
	function tratadoraAbrirSugestoes(event:SQLEvent):void
	{
		// Responsável por povoar a List e exibi-la.		
		outputSugestoes = new Array();	
		
		// Lidando com possíveis sugestões de placas de veículos não registrados:
		
		if (queryPlacas && rSugestoes is Object && rSugestoes.data is Object)
	    {
	    	for (var j:int = 0; j < rSugestoes.data.length; j++)
	    	{
	    		outputSugestoes.push(rSugestoes.data[j].PLACA.toString());
	    	}
	    	
	    	sugestoes.dataProvider = outputSugestoes;	
	    }
	    	    
	    // Agora resultados "regulares":		
		r = stmt.getResult();					
		
		if (r.data is Object)
		{	
			for (var i:int = 0; i < r.data.length; i++)
		  	{
		    	outputSugestoes.push(r.data[i][coluna]);
		    }
		    		    
		    // adição dos possíveis resultados da query de sugestões de placas de veículos não registrados:
		    sugestoes.dataProvider = outputSugestoes;		    					    		    		
		}
		
		sugestoes.dataProvider = outputSugestoes.sort();
		
		var sugestoesVisiveis:Boolean = 
				!(outputSugestoes.length == 0)
			&&	!(outputSugestoes.length == 1 && outputSugestoes[0].toString() == textInput.text);
			
		
		sugestoes.visible = sugestoesVisiveis;
		
		/*
		else
		{
			sugestoes.visible = false;
			//sugestoes.dataProvider = null;
			return;
		}
		*/
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
		
		if (!sugestoes.visible)
			return;
		
		sugestoes.visible = false;
		app.removeEventListener(MouseEvent.CLICK, tratarClique);
		app.removeEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
		sugestoes.removeEventListener(ListEvent.ITEM_CLICK, capturarSugestao);
		sugestoes.removeEventListener(KeyboardEvent.KEY_DOWN, capturarSugestao);
		sugestoes.selectedIndex= -1;
		

		//if ((UIComponent)(event.currentTarget).id == "sugestoesInput")		
		//{
		
		if (queryPlacas && !Veiculo.existePlaca(textInput.text)) 
			return;
		
			textInput.setFocus();
			textInput.setSelection(textInput.text.length, textInput.text.length);
		//}
		
	}
	
	function capturarSugestao(event:Event):void
	{
		
		// Captura um clique de mouse ou teclada sobre a List
		// e exibe o resultado no textInput
		// Uma teclada com a seta direta volta o foco sobre
		// o textInput
		
		if (event is KeyboardEvent)
		{
			
			var keyCode:uint = (KeyboardEvent)(event).keyCode;
			
			if (keyCode == Keyboard.RIGHT)
			{
				fecharSugestoes(event);
			}
			
			else if (keyCode == Keyboard.ENTER)
			{//Alert.show('==Keyboard.Enter');
				//rolarSugestoes(event);
				//Alert.show('huh');
			}
			
			else if (keyCode == Keyboard.BACKSPACE)
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
			
			if (textInput == inputModelo)
			{
				atualizarMarca();
				//inputMarca.dispatchEvent(new Event(Event.CHANGE));
			}
				
			else if (textInput == inputCor)
			{
				//inputCor.dispatchEvent(new Event(Event.CHANGE));
				atualizarCores();
			}
			
			else if (textInput == inputVeiculo)
			{//Alert.show('==inputVeiculo');
				//inputVeiculo.dispatchEvent(new Event(Event.CHANGE));
				processarInput();
			}
		}
		
		catch (e:Error)
		{
		}
		
		//Alert.show('notError');
		//textInput.setFocus();
		fecharSugestoes(event);		
	}
	
	function tratarClique(event:MouseEvent):void
	{//labelT.text += " tratarClique";				
		if 	(		!sugestoes.contains((DisplayObject)(event.target)) 
				&& 	!textInput.contains((DisplayObject)(event.target))
			)
		
			fecharSugestoes(event);
	}
	
	function tratarTeclada(event:KeyboardEvent):void
	{//labelT.text += " tratarTeclada";
		if (event.charCode == Keyboard.TAB)
		{
			//fecharSugestoes(event);
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

public function forcarSugestao(textInput:TextInput, sugestoes:List, event:FocusEvent):void
{
	
	if (event.relatedObject == sugestoes)
		return;
		
	if (textInput == inputModelo)	
	{
		/*if (textInput.text.toLowerCase() == (Array)(sugestoes.dataProvider[0]).pop().toString().toLowerCase())
		{
			textInput.text = (Array)(sugestoes.dataProvider).pop().toString();
			textInput.dispatchEvent(new Event(Event.CHANGE));
			return;
		}*/
		
		var modelos:ArrayCollection = new ArrayCollection(Modelo.getNomesModelos());
		
		if (modelos.contains(textInput.text))
		{
			sugestoes.visible = false;
			return;
		}
	}
	
	else if (textInput == inputCor)
	{
		var cores:ArrayCollection = new ArrayCollection(Cor.getNomesCores());
		
		if (cores.contains(textInput.text))
			return;
	}
	
	if 	(		textInput.text != ""
			&&	sugestoes.dataProvider is Object 
			&& 	(		sugestoes.dataProvider.length == 1 
					|| 	(	sugestoes.dataProvider.length > 1 
							&& textInput.text.toLowerCase() == sugestoes.dataProvider[0].toString().toLowerCase()
						)
				)
			//&&	!(ArrayCollection)(sugestoes.dataProvider).contains(textInput.text)
		)
	{
		try
		{
			//textInput.text = (Array)(sugestoes.dataProvider).pop().toString();
			textInput.text = sugestoes.dataProvider[0].toString();
			
			if (event.currentTarget == inputModelo || event.currentTarget == inputCor)
			
				textInput.dispatchEvent(new Event(Event.CHANGE));		
		}
		
		catch (e:Error)
		{
		}
	}
	
	sugestoes.visible = false;
}

public function resolverInput(input:TextInput):void
{
	
	if (Utils.isInteiro(input.text))
	{
		abrirSugestoes(input, "MOVIMENTACOES", "ID", sugestoesInput);
		//popupAnotacao(false);
	}
		
	else
	{
		abrirSugestoes(input, "VEICULOS", "PLACA", sugestoesInput);
		//popupAnotacao(true);
	}
		
}