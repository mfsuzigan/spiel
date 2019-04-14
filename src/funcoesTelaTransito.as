import com.spiel.Configuracoes;
import com.spiel.Cor;
import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.validators.NumberValidator;

include "funcoesSugestoes.as";
include "funcoesApp.as";
include "funcoesRecuperarVeiculo.as";
include "funcoesMecanicasTelaTransito.as";


[Bindable]
public var inputVeiculoLength:Number = 0;

[Bindable]
public var validadorNro:NumberValidator= new NumberValidator();

[Bindable]
public var tipoInput:String;

[Bindable]
public var painelCores:PainelCores;

[Bindable]
public var janelaCreditos:PainelEditarCredito;

[Bindable]
public var janelaDesfazer:PainelDesfazer;

public function initTransito():void
{
}

public function povoarTabelaComprovantesImpressos(placa:String):void
{
	// Padrão de nome de comprovante: 
	// 2675_AAA 0000_Fiat_Palio_Vermelho_(26-03-2011 12h48min51)_CORRECAO_.rtf
	
	var comprovantes:Array = comprovantesImpressos();
	var comprovantesDataProvider:Array = new Array();
	var dadosComprov:Array = new Array();
	var padraoNomeComprovante:RegExp = /^\d+_[A-Z]{3} \d{4}_.+\(\d{2}-\d{2}-\d{4} \d{2}h\d{2}min\d{2}\)_.rtf$/;
	//var padraoNomeComprovante:RegExp = /^\.*$/;
		
	for each (var comprovante:File in comprovantes)
	{
		//Alert.show(comprovante.name);
		
		if (comprovante.name == "comprovante.rtf")
			continue;
			
		else if (!padraoNomeComprovante.test(comprovante.name))
			continue;
		
		dadosComprov = comprovante.name.split("_");
		
		if (dadosComprov.length < 6)
			continue;
		
		var c:Object = new Object();
		c.nroMovimentacao = dadosComprov[0].toString();
		c.placa = dadosComprov[1].toString();
		
		if (placa != null && c.placa != placa)
		{
			continue;
		}
		
		c.marcaVeiculo = dadosComprov[2].toString();
		c.modeloVeiculo = dadosComprov[3].toString();
		c.corretivo = (dadosComprov[6].toString() == ".rtf") ? "Não" : "Sim";
		c.path = comprovante.nativePath;
		
		var horario:String = dadosComprov[5].toString();
		var timestamp:String = horario.substr(7, 4);
		timestamp += horario.substr(4, 2);
		timestamp += horario.substr(1, 2);
		timestamp += horario.substr(12, 2);
		timestamp += horario.substr(15, 2);		
		timestamp += horario.substr(20, 2);
		timestamp += "000";
		
		c.timestamp = Utils.dataFormatada(timestamp);
		
		comprovantesDataProvider.push(c);
	} 
	
	comprovantesDataProvider.sortOn("nroMovimentacao", Array.NUMERIC|Array.DESCENDING);
	tabelaComprovantesImpressos.dataProvider = comprovantesDataProvider;
}

public function mudaTextoBotoesInferiores(qualBotao:String):void
{
	// Muda a label ao lado dos botões inferiores quando mouseOver
	
	textoBotoesInferiores.text = qualBotao;
}

public function escondeAccordionsInferiores():void
{
	accordionAnotacoes.visible = false;
	accordionAjuda.visible = false;
	accordionHistorico.visible = false;
	accordionSobreOSpiel.visible = false;
	accordionReimprimir.visible = false;
}

public function isAccordionInferiorVisivel():Boolean
{
	return	(
				accordionAnotacoes.visible ||
				accordionAjuda.visible ||
				accordionHistorico.visible ||
				accordionSobreOSpiel.visible ||
				accordionReimprimir.visible
			);
}

public function disparaEfeitoAccordionAnotacoes():void
{
	// Mostra o accordion (inferior) accordionAnotacoes
	
	if (accordionAnotacoes.visible)
	{
		// se já estiver visível, esconda
		
		accordionAnotacoes.visible = false;
		moveCanvasPlaca("abaixo");
		moveBoxFerramentas("abaixo");
	}
	
	else
	{// se não estiver visível...
	
		if (isAccordionInferiorVisivel())
		{// mas o irmão estiver, esconda-o 
			escondeAccordionsInferiores();
		}
		
		else
		{  
			//Alert.show(accordionVeiculoRegistrado.visible.toString() + " " + accordionRegistrarVeiculo.visible.toString() + " " + contraido.toString());
			moveCanvasPlaca("acima");
			moveBoxFerramentas("acima");
			
			if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && !isContraido())
			{
				// Se houver um accordion direito e não estiver contraído, contraia
				
				redimensionaAccordionInferior("contrair");
				redimensionaBoxFerramentas("contrair");
			}
			
			else if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible && isContraido())
			{
				// se não houver nenhum accordion direito e estiver contraído, expanda
				
				redimensionaAccordionInferior("expandir");
				redimensionaBoxFerramentas("expandir");
			}
			
			else if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && isContraido())
			{
				// se houver e estiver contraído, não é preciso fazer nada
				
				//redimensionaAccordionInferior("contrair");
				//redimensionaBoxFerramentas("contrair");
			}		
		}
		
		accordionAnotacoes.visible = true;
	}
}

public function disparaEfeitoAccordionAjuda():void
{
	// Mostra o accordion (inferior) accordionAjuda
	
	if (accordionAjuda.visible)
	{
		// se já estiver visível, esconda
		
		accordionAjuda.visible = false;
		moveCanvasPlaca("abaixo");
		moveBoxFerramentas("abaixo");
	}
	
	else
	{// se não estiver visível...
	
		if (isAccordionInferiorVisivel())
		{// mas o irmão estiver, esconda-o 
			escondeAccordionsInferiores();
		}
		
		else
		{  
			//Alert.show(accordionVeiculoRegistrado.visible.toString() + " " + accordionRegistrarVeiculo.visible.toString() + " " + contraido.toString());
			moveCanvasPlaca("acima");
			moveBoxFerramentas("acima");
			
			if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && !isContraido())
			{
				// Se houver um accordion direito e não estiver contraído, contraia
				
				redimensionaAccordionInferior("contrair");
				redimensionaBoxFerramentas("contrair");
			}
			
			else if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible && isContraido())
			{
				// se não houver nenhum accordion direito e estiver contraído, expanda
				
				redimensionaAccordionInferior("expandir");
				redimensionaBoxFerramentas("expandir");
			}
			
			else if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && isContraido())
			{
				// se houver e estiver contraído, não é preciso fazer nada
				
				//redimensionaAccordionInferior("contrair");
				//redimensionaBoxFerramentas("contrair");
			}		
		}
		
		accordionAjuda.visible = true;
	}
}

public function disparaEfeitoAccordionHistorico():void
{
	// Mostra o accordion (inferior) accordionHistorico
	
	if (accordionHistorico.visible)
	{
		// se já estiver visível, esconda
		
		accordionHistorico.visible = false;
		moveCanvasPlaca("abaixo");
		moveBoxFerramentas("abaixo");
	}
	
	else
	{// se não estiver visível...
	
		if (isAccordionInferiorVisivel())
		{// mas o irmão estiver, esconda-o 
			escondeAccordionsInferiores();
		}
		
		else
		{  
			//Alert.show(accordionVeiculoRegistrado.visible.toString() + " " + accordionRegistrarVeiculo.visible.toString() + " " + contraido.toString());
			moveCanvasPlaca("acima");
			moveBoxFerramentas("acima");
			
			if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && !isContraido())
			{
				// Se houver um accordion direito e não estiver contraído, contraia
				
				redimensionaAccordionInferior("contrair");
				redimensionaBoxFerramentas("contrair");
			}
			
			else if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible && isContraido())
			{
				// se não houver nenhum accordion direito e estiver contraído, expanda
				
				redimensionaAccordionInferior("expandir");
				redimensionaBoxFerramentas("expandir");
			}
			
			else if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && isContraido())
			{
				// se houver e estiver contraído, não é preciso fazer nada
				
				//redimensionaAccordionInferior("contrair");
				//redimensionaBoxFerramentas("contrair");
			}		
		}
		
		accordionHistorico.visible = true;
	}
}

public function disparaEfeitoAccordionSobreOSpiel():void
{
	// Mostra o accordion (inferior) accordionHistorico
	
	if (accordionSobreOSpiel.visible)
	{
		// se já estiver visível, esconda
		
		accordionSobreOSpiel.visible = false;
		moveCanvasPlaca("abaixo");
		moveBoxFerramentas("abaixo");
	}
	
	else
	{// se não estiver visível...
	
		if (isAccordionInferiorVisivel())
		{// mas o irmão estiver, esconda-o 
			escondeAccordionsInferiores();
		}
		
		else
		{  
			//Alert.show(accordionVeiculoRegistrado.visible.toString() + " " + accordionRegistrarVeiculo.visible.toString() + " " + contraido.toString());
			moveCanvasPlaca("acima");
			moveBoxFerramentas("acima");
			
			if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && !isContraido())
			{
				// Se houver um accordion direito e não estiver contraído, contraia
				
				redimensionaAccordionInferior("contrair");
				redimensionaBoxFerramentas("contrair");
			}
			
			else if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible && isContraido())
			{
				// se não houver nenhum accordion direito e estiver contraído, expanda
				
				redimensionaAccordionInferior("expandir");
				redimensionaBoxFerramentas("expandir");
			}
			
			else if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && isContraido())
			{
				// se houver e estiver contraído, não é preciso fazer nada
				
				//redimensionaAccordionInferior("contrair");
				//redimensionaBoxFerramentas("contrair");
			}		
		}
		
		accordionSobreOSpiel.visible = true;
	}
}

public function disparaEfeitoAccordionReimprimir():void
{
	// Mostra o accordion (inferior) accordionReimprimir
	
	if (accordionReimprimir.visible)
	{
		// se já estiver visível, esconda
		
		accordionReimprimir.visible = false;
		moveCanvasPlaca("abaixo");
		moveBoxFerramentas("abaixo");
	}
	
	else
	{// se não estiver visível...
	
		if (isAccordionInferiorVisivel())
		{// mas o irmão estiver, esconda-o 
			escondeAccordionsInferiores();
		}
		
		else
		{  
			//Alert.show(accordionVeiculoRegistrado.visible.toString() + " " + accordionRegistrarVeiculo.visible.toString() + " " + contraido.toString());
			moveCanvasPlaca("acima");
			moveBoxFerramentas("acima");
			
			if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && !isContraido())
			{
				// Se houver um accordion direito e não estiver contraído, contraia
				
				redimensionaAccordionInferior("contrair");
				redimensionaBoxFerramentas("contrair");
			}
			
			else if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible && isContraido())
			{
				// se não houver nenhum accordion direito e estiver contraído, expanda
				
				redimensionaAccordionInferior("expandir");
				redimensionaBoxFerramentas("expandir");
			}
			
			else if ((accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible) && isContraido())
			{
				// se houver e estiver contraído, não é preciso fazer nada
				
				//redimensionaAccordionInferior("contrair");
				//redimensionaBoxFerramentas("contrair");
			}		
		}
		
		accordionReimprimir.visible = true;
	}
}

public function escondeAccordionDireito():void
{
	if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible)
	
		return;
	
	// Voltar à posição original, porque o direito desaparecerá
	
	moveCanvasPlaca("direita");
	
	// Desaparecendo os dois direitos:
				
	accordionVeiculoRegistrado.visible = false;
	accordionRegistrarVeiculo.visible = false;
	
	botaoEntrada.enabled = false;
	botaoSaida.enabled = false;
	
	var timer:Timer = new Timer(500);
	timer.addEventListener(TimerEvent.TIMER_COMPLETE, expandir);
	timer.start();
	
	function expandir(event:TimerEvent):void
	{
		if (isContraido())
		{
			redimensionaAccordionInferior("expandir");
			redimensionaBoxFerramentas("expandir");
		}	
	}
}

public function mostraAccordionDireito(veiculo:Veiculo):void
{	
	
	// Mostra e povoa de dados um dos dois accordions
	// do lado direito (accordionVeiculoRegistrado ou
	// accordionRegistrarVeiculo).
	
	var accordionDireitoVisivel:Boolean = (accordionVeiculoRegistrado.visible || accordionRegistrarVeiculo.visible);
	var accordionInferiorVisivel:Boolean = isAccordionInferiorVisivel();
	
	var inputV:String = inputVeiculo.text;
	
	if (accordionInferiorVisivel && !isContraido())
	{
		redimensionaAccordionInferior("contrair");
		redimensionaBoxFerramentas("contrair");
	}
	
	var isInputPlaca:Boolean = Veiculo.isPlaca(inputV);
	var isInputInteiro:Boolean = Utils.isInteiro(inputV);
	
	if ((!isInputPlaca && !isInputInteiro) || inputV == "")
	{
		// se o input não corresponde nem a uma placa nem a um código de entrada
		// ou se nenhuma string de input foi inserida
		
		escondeAccordionDireito();
		
		if (isContraido())
		{
			moveCanvasPlaca("direita");
			redimensionaAccordionInferior("expandir");
			redimensionaBoxFerramentas("expandir");
		}
		
		return;
	}
		
	var veiculoRegistrado:Boolean = !(veiculo == null) && veiculo.obterDados(inputV);
	
	if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible)
	{
		moveCanvasPlaca("esquerda");
	}
	
	if (isInputPlaca && !veiculoRegistrado)
	{
		// Se o veículo não estiver registrado
		
		//moveCanvasPlaca("esquerda");
		accordionRegistrarVeiculo.visible = true;
		accordionVeiculoRegistrado.visible = false;
		
		// Para evitar problemas, sempre resetar campos
		inputCredito.enabled = true
		inputCredito.text = "0,00";
		checkboxCobrancaNaEntrada.enabled = true;
		checkboxCobrancaNaEntrada.selected = true;
		checkboxVeiculoIsento.selected = false;
						
		// se a placa entrada for uma sugestão, preencher possíveis dados
	/*	if (Sugestao.isPlacaSugestao(inputV))
		{
			var sugestao:Sugestao = new Sugestao(inputV);
			
			inputModelo.text = sugestao.getNomeModelo();
			inputModelo.dispatchEvent(new Event(Event.CHANGE));
			sugestoesModelos.visible = false;
		
			inputCor.text = sugestao.getNomeCor();
			inputCor.dispatchEvent(new Event(Event.CHANGE));
		}*/
	}
	
	else if (isInputPlaca && veiculoRegistrado) 
	{
		// Se o veículo estiver registrado, no pátio ou não
		
		//moveCanvasPlaca("esquerda");
		accordionVeiculoRegistrado.visible = true;
		accordionRegistrarVeiculo.visible = false;
	}
	
	else if (isInputInteiro)
	{
		// se o input é um número de movimentacao
		
		accordionVeiculoRegistrado.visible = true;
		accordionRegistrarVeiculo.visible = false;
	}
}

public function fechaAccordion():void
{
	if (isAccordionInferiorVisivel())
	{
		escondeAccordionsInferiores();
		moveCanvasPlaca("abaixo");
		moveBoxFerramentas("abaixo");
	}
}

public function formatarTextoPlaca():void
{
	// Formata o texto entrado no campo de texto principal
	
	inputVeiculo.text = inputVeiculo.text.toUpperCase();
		
	var expColocarEspaco:RegExp = /^[A-Z]{3}$/;
	
	if (expColocarEspaco.test(inputVeiculo.text) && inputVeiculoLength == 2)
	{
		inputVeiculo.text = inputVeiculo.text.substr(0, 3) + " " + inputVeiculo.text.substr(3, 1);
		inputVeiculo.setSelection(5, 5);
	}
	
	inputVeiculoLength = inputVeiculo.text.length;
	
	processarInput();	
}

public function mudarCorInputVeiculo(cor:String):void
{	
	// Modifica o textInput inputVeiculo de acordo com o que foi digitado.
	
	inputVeiculo.setStyle("borderColor", (cor == "vermelho") ? 0xff0000: 0xb7babc);
}



public function processarModelo():void
{
	if (Utils.validarInput(inputModelo) == false) return;
	
	abrirSugestoes(inputModelo, "MODELOS", "NOME", sugestoesModelos);
	atualizarMarca();
	
	//}
}

public function processarCor():void
{
	if (Utils.validarInput(inputCor) == false) return;
	
	abrirSugestoes(inputCor, "CORES", "NOME", sugestoesCores);
	atualizarCores();
}

public function atualizarMarca():void
{
	atualizarTextoModeloStatus(true);
	var marcaEncontrada:String = Veiculo.getNomeMarca(inputModelo.text);
	
	if (marcaEncontrada != "")
	{
		inputMarca.text = marcaEncontrada;
	}
	
	else
	{
		inputMarca.text = "";
		
		if (inputModelo.text != "")
		{
			atualizarTextoModeloStatus(false);
		}
	}
}

public function atualizarTextoModeloStatus(resetarLabel:Boolean):void
{
	if (resetarLabel)
	{
		textoModeloStatus.clearStyle("color");
		//textoModeloStatus.clearStyle("fontWeight");
		textoModeloStatus.text = "Modelo:";
		textoModeloStatus.clearStyle("color");
		//inputModelo.clearStyle("borderColor");
		inputModelo.clearStyle("backgroundColor");
		inputModelo.clearStyle("color");
		
	}
	
	else
	{
		textoModeloStatus.setStyle("color", 0xaa3400);
		//textoModeloStatus.setStyle("fontWeight", "bold");
		textoModeloStatus.text = "Modelo não encontrado:";
		textoModeloStatus.setStyle("color", 0xffffff);
		//inputModelo.setStyle("borderColor", 0xff0000);
		inputModelo.setStyle("backgroundColor", 0xff0000);
		inputModelo.setStyle("color", 0xffffff);
	}
}

public function atualizarCores():void
{	
	atualizarTextoCoresStatus(true);
	var codCorEncontrada:String = Cor.getCodigo(inputCor.text);
	
	if (codCorEncontrada != "")
	{
		quadroCores.setStyle("backgroundColor", codCorEncontrada);
		labelInterrogacao.visible = false;
		
		if (codCorEncontrada == Cor.getCodigo("Outra"))
		{
			labelInterrogacao.text = "!";
			labelInterrogacao.visible = true;
		}
	}
	
	else
	{		
		if (inputCor.text != "")
		{
			atualizarTextoCoresStatus(false);
		}
	}
}

public function atualizarTextoCoresStatus(resetarLabel:Boolean):void
{
	if (resetarLabel)
	{
		textoCorStatus.clearStyle("color");
		//textoCorStatus.clearStyle("fontWeight");
		textoCorStatus.text = "Cor:";
		//inputModelo.clearStyle("borderColor");
		inputCor.clearStyle("backgroundColor");
		inputCor.clearStyle("color");
	}
	
	else
	{
		textoCorStatus.setStyle("color", 0xffffff);
		//textoCorStatus.setStyle("fontWeight", "bold");
		textoCorStatus.text = "Cor não encontrada:";
		//inputModelo.setStyle("borderColor", 0xff0000);
		inputCor.setStyle("backgroundColor", 0xff0000);
		inputCor.setStyle("color", 0xffffff);
	}
	
	quadroCores.setStyle("backgroundColor", 0xffffff);
	labelInterrogacao.text = "?";
	labelInterrogacao.visible = true;
}

public function abrirPainelCores():void
{
	painelCores = new PainelCores();	
	Application.application.addChild(painelCores);
	//painelCores.id = "painelCores";
	painelCores.setStyle("horizontalCenter", 0);
	painelCores.setStyle("verticalCenter", 0);
	painelCores.addEventListener(CloseEvent.CLOSE, fecharPainelCores);
	desabilitarAplicacaoExceto(painelCores);
	painelCores.setFocus();
}

public function fecharPainelCores(event:CloseEvent):void
{
	Application.application.removeChild(painelCores);
	habilitarAplicacao();
	
	if (painelCores.corSelecionada != "")
		inputCor.text = painelCores.corSelecionada;
		
	atualizarCores();
}

public function atualizarStatusInput():void
{
	escondeAccordionDireito();
	inputVeiculo.dispatchEvent(new Event(Event.CHANGE));
}

public function mostrarCanvasMensagem(mostrarCanvasEfetuarCobranca:Boolean, mostrarCanvasCreditoDeduzido:Boolean, mostrarCanvasCreditoInsuficiente:Boolean):void
{
	canvasEfetuarCobranca.visible = (mostrarCanvasEfetuarCobranca && !mostrarCanvasCreditoDeduzido);
	labelEfetuarCobranca.text = "Efetuar cobrança de R$ " + Utils.formatarDinheiro(Configuracoes.getTarifa()); 
	
	canvasCreditoDeduzido.visible = mostrarCanvasCreditoDeduzido;
	labelCreditoDeduzido.text = labelCreditoDeduzido.text.substr(0, labelCreditoDeduzido.text.length - 1);
	labelCreditoDeduzido.text += Configuracoes.getTarifa();
	
	canvasCreditoInsuficiente.visible = (mostrarCanvasEfetuarCobranca && mostrarCanvasCreditoInsuficiente);
	
	if (canvasCreditoInsuficiente.visible)
	{
		var v:Veiculo = new Veiculo();
		
		if (Utils.isInteiro(inputVeiculo.text))
		{
			v = Movimentacao.getVeiculoAssociado(inputVeiculo.text);
		}
		
		else
		{
			v.obterDados(inputVeiculo.text);
		}
		
		labelCreditoInsuficiente.text = "Créditos do veículo insuficientes: R$ " + Utils.formatarDinheiro(v.getCredito());
	}
	//Alert.show(mostrarCanvasEfetuarCobranca.toString() + " " + mostrarCanvasCreditoDeduzido.toString()
	
	timerCanvasMensagem.removeEventListener(TimerEvent.TIMER, retirarCanvasMensagem);
	timerCanvasMensagem.removeEventListener(TimerEvent.TIMER, retirarCanvasMensagemGenerica);	
	timerCanvasMensagem.addEventListener(TimerEvent.TIMER, retirarCanvasMensagem);
	
	if (timerCanvasMensagem.running)
	{
		canvasMensagem.visible = false;
		canvasMensagemGenerica.visible = false;
		timerCanvasMensagem.stop();
		//timerCanvasMensagem.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
	}
	
	canvasMensagem.visible = true;
	timerCanvasMensagem.start();
}

public function retirarCanvasMensagem(event:TimerEvent):void
{
	canvasEfetuarCobranca.visible = false;
	canvasCreditoDeduzido.visible = false;
	canvasCreditoInsuficiente.visible = false;
	canvasMensagem.visible = false;
	timerCanvasMensagem.stop();
}

public function mostrarCanvasMensagemGenerica(mensagem:String, hora:String, d:String):void
{
	labelMensagemGenerica.text = mensagem;
	labelInstanteMensagemGenerica.text = hora;
	labelDataMensagemGenerica.text = d;
	
	timerCanvasMensagem.removeEventListener(TimerEvent.TIMER, retirarCanvasMensagem);
	timerCanvasMensagem.removeEventListener(TimerEvent.TIMER, retirarCanvasMensagemGenerica);	
	timerCanvasMensagem.addEventListener(TimerEvent.TIMER, retirarCanvasMensagemGenerica);
	
	if (timerCanvasMensagem.running)
	{
		canvasMensagem.visible = false;
		canvasMensagemGenerica.visible = false;
		timerCanvasMensagem.stop();
		//timerCanvasMensagem.dispatchEvent(new TimerEvent(TimerEvent.TIMER));
	}
	
	canvasEfetuarCobranca.visible = false;
	canvasCreditoDeduzido.visible = false;
	
	canvasMensagemGenerica.visible = true;
	timerCanvasMensagem.start();
}

public function retirarCanvasMensagemGenerica(event:TimerEvent):void
{
	canvasMensagemGenerica.visible = false;
	timerCanvasMensagem.stop();
}

public function tratarEnterInputVeiculo():void
{
	if (!accordionVeiculoRegistrado.visible && !accordionRegistrarVeiculo.visible)
		return;
		
	Application.application.timerMensagemAguarde.stop();
	Application.application.mensagemAguarde.visible = true;
	Application.application.timerMensagemAguarde.addEventListener(TimerEvent.TIMER, fInterna);
	Application.application.timerMensagemAguarde.start();
	
	function fInterna(event:TimerEvent):void
	{
		if (botaoSaida.enabled)
		{
			saidaDoPatio(inputVeiculo.text);
		}
		
		else if (botaoEntrada.enabled)
		{
			entradaNoPatio(inputVeiculo.text);
		}
	}
}

public function mostrarJanelaEditarCreditos():void
{
	janelaCreditos = new PainelEditarCredito();
	Application.application.addChild(janelaCreditos);
	janelaCreditos.setStyle("horizontalCenter", 0);
	janelaCreditos.setStyle("verticalCenter", 0);
	janelaCreditos.povoar(inputVeiculo.text);
	janelaCreditos.addEventListener(CloseEvent.CLOSE, fecharJanelaEditarCreditos);
	desabilitarAplicacaoExceto(janelaCreditos);
}

public function fecharJanelaEditarCreditos(event:CloseEvent):void
{
	Application.application.removeChild(janelaCreditos);
	habilitarAplicacao();
	
	if (janelaCreditos.creditoFoiMudado)
	{
		var dFlush:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(0, 10);
		var horaFlush:String = Utils.dataFormatada(Utils.getStringAgora(false)).substr(11, 8);
		mostrarCanvasMensagemGenerica("Créditos do veículo editados com sucesso.", horaFlush, dFlush);
	}
}

public function mostrarJanelaDesfazer():void
{
	janelaDesfazer = new PainelDesfazer();
	Application.application.addChild(janelaDesfazer);
	janelaDesfazer.setStyle("horizontalCenter", 0);
	janelaDesfazer.setStyle("verticalCenter", 0);
	janelaDesfazer.addEventListener(CloseEvent.CLOSE, fecharJanelaEditarDesfazer);
	desabilitarAplicacaoExceto(janelaDesfazer);
}

public function fecharJanelaEditarDesfazer(event:CloseEvent):void
{
	Application.application.removeChild(janelaDesfazer);
	inputVeiculo.dispatchEvent(new Event(Event.CHANGE));
	habilitarAplicacao();	
}

public function tratarEnterInputCor(event:FlexEvent):void
{
	inputCor.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
	botaoRegistrarVeiculo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
}

public function tratarEnterInputModelo(event:FlexEvent):void
{
	if (!Utils.validarInput(inputModelo))
		return;
	
	inputModelo.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
	botaoRegistrarVeiculo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
}

public function tratarEnterInputCredito():void
{
	botaoRegistrarVeiculo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
}

public function confirmarEsvaziarPatio():void
{
	Alert.show(
		"Isso dará baixa a todos os carros no pátio. Deseja prosseguir?",
		"Esvaziar pátio",
		Alert.YES|Alert.NO,
		null,
		interna
	);
		
	function interna(event:CloseEvent):void
	{
		Application.application.mensagemAguarde.visible = true;	
		
		if (event.detail == Alert.NO)
		{	
			Application.application.mensagemAguarde.visible = false;
			return;
		}
			
		if (Movimentacao.placasDeVeiculosNoPatio().length == 0)
		{
			Application.application.mensagemAguarde.visible = false;
			Alert.show("No momento não há veículos no pátio.", "Esvaziar pátio");
			return;
		}
			
		Application.application.timerMensagemAguarde.addEventListener(TimerEvent.TIMER, esvaziarPatio);
		Application.application.timerMensagemAguarde.start();
	}
}

public function labelStatusModoSomenteEntradas():String
{
	return (Application.application.modoSomenteEntradas) ? "Desativar modo Somente Entradas" : "Ativar modo Somente Entradas";
}

public function toggleModoSomenteEntradas():void
{
	Application.application.modoSomenteEntradas = !Application.application.modoSomenteEntradas;
	mudaTextoBotoesInferiores(labelStatusModoSomenteEntradas())
	var modoNormal:Boolean = !Application.application.modoSomenteEntradas;
	
	botaoSaida.visible = modoNormal;
	labelModoSomenteEntradas.visible = !modoNormal;
	botaoEntrada.setStyle("horizontalCenter", (modoNormal) ? -125 : 0);
	inputVeiculo.dispatchEvent(new Event(Event.CHANGE));
}

public function comprovantesImpressos():Array
{
	var dirApp:String = File.applicationDirectory.nativePath;
	dirApp.replace("\\", "\\\\");
	
	var dirComprovantes:String = 
		dirApp 
		+ "\\resources\\comprovantes\\";
		
	return new File(dirComprovantes).getDirectoryListing();
}