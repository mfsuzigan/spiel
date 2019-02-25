// ActionScript file

import com.spiel.Conexao;
import com.spiel.Cor;
import com.spiel.Modelo;
import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.validators.RegExpValidator;

[Bindable]
private var inputVeiculoLength:Number = 0;

[Bindable]
private var validadorPlaca:RegExpValidator = new RegExpValidator();

[Bindable]
public var painelCores:PainelCores;

[Bindable]
private var placaInicial:String;

public function initPainelEditarVeiculo():void
{
	tabelaHistorico.colunaVeiculo.visible = false;
	
}
/*
public function trataCliqueBotaoApagar():void
{
	var veiculo:Veiculo = new Veiculo();
	veiculo.obterDados(Application.application.telaBusca.tabelaBusca.selectedItem.placa.toString());
	confirmarExclusaoVeiculo(veiculo);
}

public function confirmarExclusaoVeiculo(v:Veiculo):void
{
	Alert.show("Deseja realmente excluir este veículo e todos os dados associados (movimentações e anotações)?",
		v.getPlaca(),
		Alert.YES|Alert.NO,
		null,
		tratarConfirmarExclusao
		);
		
	function tratarConfirmarExclusao(event:CloseEvent):void
	{
		if (event.detail == Alert.YES)
		{
			v.remover();
			Application.application.telaBusca.atualizarTabelaBusca();
			Application.application.atualizarEstatisticas();
			Application.application.telaBusca.desabilitarBotoes();
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			Alert.show("Veículo excluído com sucesso.", "Veículo excluído");
		}
	}
}
*/

public function povoar(placa:String):void
{
	placaInicial = placa;
	
	var veiculo:Veiculo = new Veiculo();
	veiculo.obterDados(placa);
	
	this.title = "Dados do veículo de placa " + 
		veiculo.getPlaca() + 
		" (" + veiculo.getNomeMarca() + " " + veiculo.getNomeModelo() + ")";
	
	inputPlaca.text = placa;
	inputModelo.text = veiculo.getNomeModelo();
	inputMarca.text = veiculo.getNomeMarca();
	inputCor.text = Cor.getNome(veiculo.getIdCor());
	
	if (inputCor.text == "Vinho" || inputCor.text == "Marrom" || inputCor.text == "Azul")
	{
		inputCor.setStyle("color", 0xffffff);
	}
	
	if (veiculo.getNomeCor() == "Preto")
		inputCor.setStyle("backgroundColor", Cor.getCodigo("Branco"));
	
	else
		inputCor.setStyle("backgroundColor", veiculo.getIdCor());
	
	inputCredito.text = Utils.formatarDinheiro(veiculo.getCredito());
	
	checkboxIsento.selected = (veiculo.getIsento() == "1");
	
	var noPatio:Boolean = (Movimentacao.getCodigoUltimaMovimentacao(placa).toString() == "1");
		
	if (noPatio)
	{
		labelStatus.text = "No pátio";
		labelIdMovimentacao.text = Movimentacao.getIdUltimaMovimentacao(placa).toString();
		imagemStatus.load("resources\\icones\\green_shield.png");
		
	}
	
	else
	{
		labelStatus.text = "Fora do pátio";
		labelIdMovimentacao.text = "-";
		imagemStatus.load("resources\\icones\\rain.png");
	
	}
	
	tabelaHistorico.povoar(placa, null, null);
}

public function formatarTextoPlaca():void
{
	// Formata o texto entrado no campo de texto principal
	
	inputPlaca.text = inputPlaca.text.toUpperCase();
		
	var expColocarEspaco:RegExp = /^[A-Z]{3}$/;
	
	if (expColocarEspaco.test(inputPlaca.text) && inputVeiculoLength == 2)
	{
		inputPlaca.text = inputPlaca.text.substr(0, 3) + " " + inputPlaca.text.substr(3, 1);
		inputPlaca.setSelection(5, 5);
	}
	
	inputVeiculoLength = inputPlaca.text.length;
	
	validarPlaca();
}

public function validarPlaca():Boolean
{	
	validadorPlaca = new RegExpValidator();
	validadorPlaca.noMatchError = "Placa inválida";
	validadorPlaca.requiredFieldError = "Insira uma placa válida"
	validadorPlaca.source = inputPlaca;
	validadorPlaca.required = true;
	validadorPlaca.property = "text";
	validadorPlaca.expression = "^[A-Z]{3} [0-9]{4}$";
	var resultadoValidacao:ValidationResultEvent = validadorPlaca.validate();
	
	botaoSalvar.enabled = (resultadoValidacao.type == ValidationResultEvent.VALID);
	return botaoSalvar.enabled;	
}


//////

public function processarModelo():void
{
	abrirSugestoes(inputModelo, "MODELOS", "NOME", sugestoesModelos);
	atualizarMarca();
}

public function processarCor():void
{
	
	abrirSugestoes(inputCor, "CORES", "NOME", sugestoesCores);
	atualizarCores();
}

public function atualizarMarca():void
{
	
	//atualizarTextoModeloStatus(true);
	var marcaEncontrada:String = Veiculo.getNomeMarca(inputModelo.text);
	
	if (marcaEncontrada != "")
	{
		inputMarca.text = marcaEncontrada;
	}
	
	else
	{
		inputMarca.text = "";
	}
}

public function atualizarCores():void
{	
	var codCorEncontrada:String = Cor.getCodigo(inputCor.text);
	
	if (codCorEncontrada != "")
	{
		if (inputCor.text == "Vinho" || inputCor.text == "Marrom" || inputCor.text == "Azul")
			inputCor.setStyle("color", 0xffffff);
		
		else
			inputCor.setStyle("color", 0x000000);
				
		
		if (codCorEncontrada == Cor.getCodigo("Preto"))
			inputCor.setStyle("backgroundColor", Cor.getCodigo("Branco"));	
		
		else
			inputCor.setStyle("backgroundColor", codCorEncontrada);
	}
	
	else
	{		
		if (inputCor.text != "")
		{
		}
	}
}

public function abrirPainelCores():void
{
	painelCores = new PainelCores();	
	Application.application.addChild(painelCores);
	Application.application.desabilitarAplicacaoExceto(painelCores);
	//painelCores.id = "painelCores";
	painelCores.setStyle("horizontalCenter", 20);
	painelCores.setStyle("verticalCenter", -20);
	painelCores.addEventListener(CloseEvent.CLOSE, fecharPainelCores);
	painelCores.setFocus();
}

public function fecharPainelCores(event:CloseEvent):void
{
	Application.application.removeChild(painelCores);
	Application.application.habilitarAplicacao();
	this.setFocus();
	
	if (painelCores.corSelecionada != "")
		inputCor.text = painelCores.corSelecionada;
		
	
	atualizarCores();
}

public function abrirSugestoes(textInput:TextInput, tabela:String, coluna:String, sugestoes:List):void
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
					
	var app:PainelEditarVeiculo = this;				
	app.addEventListener(MouseEvent.CLICK, tratarClique);
	app.addEventListener(KeyboardEvent.KEY_DOWN, tratarTeclada);
	
	var outputSugestoes:Array = new Array();
	var r:SQLResult;
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = Conexao.get();
		
	stmt.text = "" +
		"SELECT " + coluna + ((tabela == "MOVIMENTACOES" && coluna == "ID") ? ", PLACA AS P " : " ") +
		"FROM " + tabela + " " +
		"WHERE " + coluna + " LIKE '" + textInput.text + "%' " + 
		"ORDER BY " + coluna + ";";
		
	//Alert.show(stmt.text);
			
	stmt.addEventListener(SQLEvent.RESULT, tratadoraAbrirSugestoes);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraAbrirSugestoesErro);
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
			sugestoes.dataProvider = null;
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
			/*
			else if (textInput == inputVeiculo)
			{//Alert.show('==inputVeiculo');
				//inputVeiculo.dispatchEvent(new Event(Event.CHANGE));
				processarInput();
			}
			*/
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
			return;
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

public function formatarTextoInputCredito(event:Event):void
{
	if (inputCredito.text.search(",") == -1)
	{
		inputCredito.text = (inputCredito.text == "" ? "0" : inputCredito.text) + ",00";
	}
}

public function validarInsercaoVeiculo():void
{
	if (inputModelo.text == "" || inputMarca.text == "")
	{
		Alert.show("Você deve escolher um modelo de veículo válido.", "Erro");
		return;
	}
	
	var codCorEncontrada:String = Cor.getCodigo(inputCor.text);
	
	if (inputCor.text == "" || codCorEncontrada == "")
	{
		Alert.show("Você deve escolher uma cor de veículo válida.", "Erro");
		return;
	}
	
	if (inputPlaca.text != placaInicial && Veiculo.existePlaca(inputPlaca.text))
	{
		Alert.show("Já existe veículo registrado sob tal placa.", "Erro");
		return;
	}
	
	if (	validadorInputCredito.validate().type == ValidationResultEvent.VALID
			&& validarPlaca()
		)
	{
		var v:Veiculo = new Veiculo();
		var m:Modelo = new Modelo(false, null, null);
		m.obterDados(inputModelo.text);
		
		v.obterDados(Application.application.telaBusca.tabelaBusca.selectedItem.placa.toString());
		v.setIdCor(Cor.getCodigo(inputCor.text));
		v.setIdModelo(m.getId());
		v.setCredito(creditoValidado(inputCredito.text));
		v.setIsento(checkboxIsento.selected ? "1" : "0");
		v.flush(inputPlaca.text);
		Application.application.telaBusca.atualizarTabelaBusca();
		this.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		Alert.show("Dados do veículo atualizados com sucesso.", "Dados atualizados");
		
		var movimentacao:Movimentacao = new Movimentacao(true, null, 0, 0, false);
		movimentacao.obterDados(Movimentacao.getIdUltimaMovimentacao(v.getPlaca()).toString());
		
		if (movimentacao.getCodigoMovimentacao() == Movimentacao.COD_ENTRADA)
		{
			Application.application.imprimirComprovante(movimentacao, true);
			Application.application.flashIconeImprimindoPequeno();
		}
		
		Application.application.telaBusca.atualizarTabelaBusca();
	}
	
}

public function creditoValidado(valor:String):String
{
	return valor.replace(",", ".");
}