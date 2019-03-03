// ActionScript file

import com.spiel.Configuracoes;
import com.spiel.Cor;
import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.containers.TitleWindow;
import mx.controls.Alert;
import mx.controls.Label;
import mx.core.Application;
import mx.core.UIComponent;
import mx.events.CloseEvent;

[Bindable]
public var timerMensagemAguarde:Timer = new Timer(100, 1);

[Bindable]
public var telaTransito:TelaTransito;

[Bindable]
public var telaPatio:TelaPatio;

[Bindable]
public var telaBusca:TelaBusca;

[Bindable]
public var telaConfiguracoes:TelaConfiguracoes;

[Bindable]
public var telaFinanceiro:TelaFinanceiro;

[Bindable]
public var painelSenha:PainelSenha;

[Bindable]
public var painelRelatorios:PainelRelatorios;

[Bindable]
public var timerImpressora:Timer;

[Bindable]
public var timerImpressoraPequeno:Timer;

[Bindable]
public var modoSomenteEntradas:Boolean = false;

[Bindable]
private var pathUltimoComprovanteImpresso:String;

[Bindable]
public var resumoDeRelatorio:String;

[Bindable]
public var imprimirResumo:Boolean = false;
//
//[Bindable]
//public var placasDeComprovantes:Array = new Array();

include "modeloDeResumoDeRelatorio.as";

public const TELA_TRANSITO:Number = 0;
public const TELA_PATIO:Number = 1;
public const TELA_BUSCA:Number = 2;
public const TELA_CONFIGURACOES:Number = 3;
public const TELA_FINANCEIRO:Number = 4;
        
public function init():void
{
	stage.nativeWindow.maximize();
	stage.nativeWindow.alwaysInFront = false;
	
	telaTransito = new TelaTransito();	
	telaPatio = new TelaPatio();
	telaBusca = new TelaBusca();
	telaConfiguracoes = new TelaConfiguracoes();	
	telaFinanceiro = new TelaFinanceiro();
	
	telaPatio.visible = 
	telaBusca.visible = 
	telaFinanceiro.visible=
	telaConfiguracoes.visible = false;
	
	Application.application.frameDireito.addChild(telaTransito);
	Application.application.frameDireito.addChild(telaPatio);
	Application.application.frameDireito.addChild(telaBusca);	
	Application.application.frameDireito.addChild(telaConfiguracoes);	
	Application.application.frameDireito.addChild(telaFinanceiro);
	
	Alert.yesLabel = "Sim";
	Alert.noLabel = "Não";
	
	Application.application.hoje = Utils.getStringHojeSemHorario();
	Application.application.nroVeiculosNoPatioHoje = Veiculo.nroVeiculosNoPatioHoje();
	Application.application.nroBaixas = Veiculo.nroBaixasHoje();

	verificarPatio();
	atualizarEstatisticas(false);
}

public function flashIconeImprimindo():void
{
	if (!timerImpressora is Object)
	{
		timerImpressora = new Timer(600, 10);
		timerImpressora.addEventListener(TimerEvent.TIMER, funcaoTimerImpressora);
		timerImpressora.addEventListener(TimerEvent.TIMER_COMPLETE, funcaoTimerImpressoraCompleto);
	}
	
	if (timerImpressora.running)
		timerImpressora.stop();
		
	timerImpressora.start();
	
	function funcaoTimerImpressora(event:TimerEvent):void
	{
		Application.application.telaTransito.imagemImpressora.visible = !Application.application.telaTransito.imagemImpressora.visible
	}	
	
	function funcaoTimerImpressoraCompleto(event:TimerEvent):void
	{
		Application.application.telaTransito.imagemImpressora.visible = false;
		timerImpressora.stop();
	}
}

public function flashIconeImprimindoPequeno():void
{
	
	if (!timerImpressoraPequeno is Object)
	{
		timerImpressoraPequeno = new Timer(600, 15);
		timerImpressoraPequeno.addEventListener(TimerEvent.TIMER, funcaotimerImpressoraPequeno);
		timerImpressoraPequeno.addEventListener(TimerEvent.TIMER_COMPLETE, funcaotimerImpressoraPequenoCompleto);
	}
	
	if (timerImpressoraPequeno.running)
		timerImpressoraPequeno.stop();
		
	timerImpressoraPequeno.start();
	
	function funcaotimerImpressoraPequeno(event:TimerEvent):void
	{
		Application.application.telaBusca.imagemImpressoraPequena.visible =
		Application.application.telaBusca.labelComprovanteCorretivo.visible =
			 !Application.application.telaBusca.imagemImpressoraPequena.visible
			 
			 //Alert.show("tick");
	}	
	
	function funcaotimerImpressoraPequenoCompleto(event:TimerEvent):void
	{
		Application.application.telaBusca.imagemImpressoraPequena.visible =
		Application.application.telaBusca.labelComprovanteCorretivo.visible = 
		false;
		
		timerImpressoraPequeno.stop();
	}
}

private function obterTemplateComprovante(idMovimentacao:String, timestamp:String, 
placa:String, marca:String, modelo:String, cor:String,
valorTarifaPaga:String, tarifaPaga:String):String{
	var conteudo:String =
		"{\\rtf1\\ansi\\ansicpg1252\\deff0\\deflang1046{\\fonttbl{\\f0\\fswiss\\fcharset0 Arial;}}" +
		"{\\*\\generator Msftedit 5.41.15.1515;}\\viewkind4\\uc1\\pard\\f0\\fs24 ------------------------------------------------------\\par" +
		"|  \\b Complexo Assistencial Dr. Hansen\\b0\\par" +
		"|               \\b Estacionamento\\b0\\par" +
		"|       \\b Comprovante de Entrada\\b0\\par" +
		"|\\par" +
		"|          C\\'f3d.:\\b\\fs44 " + idMovimentacao + "\\b0\\fs24\\par" +
		"|\\par" +
		"|          " + timestamp + "\\par" +
		"|\\par" +
		"|          . Placa: \\b " + placa + "\\b0\\par" +
		"|          . Marca: " + marca + "\\par" +
		"|          . Modelo: " + modelo + "\\par" +
		"|          . Cor: " + cor + "\\par" +
		"|          . Tarifa: R$ " + valorTarifaPaga + " (" + tarifaPaga + ")\\par" +
		"|\\par" +
		"|    \\b Obs.: n\\'e3o nos responsabilizamos\\b0\\par" +
		"|    \\b por bens deixados no ve\\'edculo\\b0\\par" +
		"------------------------------------------------------\\fs20\\par" +
		"}";
		
		return conteudo;
}

public function imprimirComprovante(mov:Movimentacao, isCorrecao:Boolean):void
{
	var dirApp:String = File.applicationDirectory.nativePath;
	dirApp.replace("\\", "\\\\");
	
	var veiculo:Veiculo = mov.getVeiculoAssociado();
	var placa:String = veiculo.getPlaca();
	var cor:String = Cor.getNome(veiculo.getIdCor());
	var timestamp:String = Utils.dataFormatadaHifen(mov.getT());
	var timestamp_:String = Utils.dataFormatada(mov.getT());
	var marca:String = veiculo.getNomeMarca();
	var modelo:String = veiculo.getNomeModelo();
	var nomeCarro:String = marca + "_" + modelo;
	
	var n:Number = Movimentacao.getIdUltimaMovimentacao(veiculo.getPlaca());
	var idMovimentacao:String = "";
	
	if (n < 10)
		idMovimentacao = "000" + n.toString();
	else if (n>= 10 && n <= 100)
		idMovimentacao = "00" + n.toString();
	else if (n >= 100 && n < 1000)
		idMovimentacao = "0" + n.toString();
	else if  (n>=100)
		idMovimentacao = n.toString();
		
	var dirBackup:String = dirApp 
		+ "\\resources\\comprovantes\\" 
		+ idMovimentacao 
		+ "_" 
		+ placa 
		+  "_" 
		+ nomeCarro 
		+ "_" 
		+ cor
		+ "_(" + timestamp  + ")"
		+ ((isCorrecao) ? "_CORRECAO" : "")
		+ "_.rtf";
		
	var caminhoComprovante:String = dirApp + "\\resources\\comprovantes\\comprovante.rtf";
	
	var comprovante:File = new File(caminhoComprovante);	
	var comprovanteStream:FileStream = new FileStream();
	comprovanteStream.open(comprovante, FileMode.WRITE);
	
	var backup:File = new File(dirBackup);	
	var backupStream:FileStream = new FileStream();
	backupStream.open(backup, FileMode.WRITE);
		
	var tarifaPaga:String = "";
	var valorTarifaPaga:String;
	
	if (veiculo.getIsento() == "1")
	{
		tarifaPaga += "isento";
		valorTarifaPaga = "0,00";
	}
		
	else if (mov.getCobrancaNaEntrada())
	{
		tarifaPaga += "paga";
		valorTarifaPaga = Utils.formatarDinheiro(Configuracoes.getTarifa());
	}
		
	else
	{
		tarifaPaga = "a pagar";
		valorTarifaPaga = Utils.formatarDinheiro(Configuracoes.getTarifa());
	}
	
	
	var conteudoComprovante:String = obterTemplateComprovante(idMovimentacao, timestamp_,placa, marca, modelo, cor, valorTarifaPaga, tarifaPaga);
	comprovanteStream.writeMultiByte(conteudoComprovante, "iso-8859-1");
	comprovanteStream.close();
	
	backupStream.writeMultiByte(conteudoComprovante, "iso-8859-1");
	backupStream.close();
	imprimirComWordpad(caminhoComprovante);
	
	flashIconeImprimindo();
	
	var comprovanteImpresso:Object = new Object();
	comprovanteImpresso.nroMovimentacao = n;
	comprovanteImpresso.placa = placa;
	comprovanteImpresso.marcaVeiculo = veiculo.getNomeMarca();
	comprovanteImpresso.modeloVeiculo = veiculo.getNomeModelo();
	comprovanteImpresso.path = dirBackup;
	comprovanteImpresso.timestamp = timestamp_;
	comprovanteImpresso.corretivo = (isCorrecao) ? "Sim" : "Não";
	
	Application.application.telaTransito.povoarTabelaComprovantesImpressos(null);
	
}

private function imprimirComWordpad(caminhoComprovante:String):void {
	var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    var file:File = File.applicationDirectory.resolvePath("etc\\wordpad\\wordpad.exe");
    nativeProcessStartupInfo.executable = file;
    
    var processArgs:Vector.<String> = new Vector.<String>();
    processArgs[0] = "/p";
    processArgs[1] = caminhoComprovante;
    nativeProcessStartupInfo.arguments = processArgs;
    
    new NativeProcess().start(nativeProcessStartupInfo);
}

public function reimprimirUltimoComprovante():void
{		
	var dirApp:String = File.applicationDirectory.nativePath;
	dirApp.replace("\\", "\\\\");
	
	var dirComprovantes:String = 
		dirApp 
		+ "\\resources\\comprovantes\\";
	
	var pathComprovanteGeral:String = dirComprovantes + "comprovante.rtf";
			
	var comprovante:File = new File(pathComprovanteGeral);
	var comprovanteStream:FileStream = new FileStream();
	comprovanteStream.open(comprovante, FileMode.APPEND);
	comprovanteStream.writeMultiByte(".", "iso-8859-1");
	comprovanteStream.close();
	imprimirComWordpad(pathComprovanteGeral);
	
	flashIconeImprimindo();
}

public function imprimirResumoDeRelatorio():void
{
	var dirApp:String = File.applicationDirectory.nativePath;
	dirApp.replace("\\", "\\\\");
	
	var dirComprovantes:String = 
		dirApp 
		+ "\\resources\\comprovantes\\";
	
	var pathComprovanteGeral:String = dirComprovantes + "comprovante.rtf";
			
	var comprovante:File = new File(pathComprovanteGeral);
	var comprovanteStream:FileStream = new FileStream();
	comprovanteStream.open(comprovante, FileMode.WRITE);
	comprovanteStream.writeMultiByte(resumoDeRelatorio, "iso-8859-1");
	comprovanteStream.close();
	imprimirComWordpad(pathComprovanteGeral);
	
	flashIconeImprimindo();
}

public function reimprimirComprovante(item:Object):void
{	
	// path do comprovante a ser impresso:
	var pathComprovanteAlvo:String = item.path.toString();
	
	if (pathUltimoComprovanteImpresso == pathComprovanteAlvo)
	{
		reimprimirUltimoComprovante();
	} 	
	
	else 
	{
		pathUltimoComprovanteImpresso = pathComprovanteAlvo;
		
		// dir da application	
		var dirApp:String = File.applicationDirectory.nativePath;
		dirApp.replace("\\", "\\\\");
		
		// dir dos comprovantes
		var dirComprovantes:String = 
			dirApp 
			+ "\\resources\\comprovantes\\";
			
		// path do comprovante geral:
		var pathComprovanteGeral:String = dirComprovantes + "comprovante.rtf";
	
		// copiar para o comprovante geral o comprovante a ser impresso:
		var comprovante:File = new File(pathComprovanteAlvo);	
		comprovante.copyTo(new File(pathComprovanteGeral), true);
		imprimirComWordpad(pathComprovanteGeral);
			
		flashIconeImprimindo();
	}
	
	Application.application.telaTransito.botaoReimprimirComprovante.enabled = false;
	Application.application.telaTransito.tabelaComprovantesImpressos.selectedIndex = -1;
}

public function childrenInvisiveis():void
{
	var children:Array = Application.application.frameDireito.getChildren();
	
	for (var i:Number = 0; i < children.length; i++)
	{
		(UIComponent)(children[i]).visible = false;
	}
}

public function temChild(componente:UIComponent):Boolean
{
	var children:Array = Application.application.frameDireito.getChildren();
	
	for (var i:Number = 0; i < children.length; i++)
	{
		if ((UIComponent)(children[i]).className == componente.className)
		{
			return true;
		}
	}
	
	return false;
}

public function mostrarTela(tela:Number):void
{
	if (Application.application.frameDireito.getChildAt(tela).visible)
		return;
		
	childrenInvisiveis();
	
	Application.application.mensagemAguarde.visible = true;
	var timer:Timer = new Timer(100);
	timer.addEventListener(TimerEvent.TIMER, interna);
	timer.start();
	
	function interna(event:TimerEvent):void
	{
		timer.stop();
		Application.application.frameDireito.getChildAt(tela).visible = true;
		Application.application.mensagemAguarde.visible = false;
	}
}

public function desabilitarAplicacaoExceto(componente:UIComponent):void
{
	// Desabilita toda a aplicação, exceto o componente que vem como argumento
	
	var children:Array = Application.application.getChildren();
								
	for (var i:Number = 0; i < children.length; i++)
	{
		(UIComponent)(children[i]).enabled = (children[i] == componente);
	}
}

public function habilitarAplicacao():void
{
	// Habilita toda a aplicação
	
	var children:Array = Application.application.getChildren();
								
	for (var i:Number = 0; i < children.length; i++)
	{
		(UIComponent)(children[i]).enabled = true;
	}
}

public function atualizarEstatisticas(forceGet:Boolean):void
{
	var childrenFrameEsquerdo:Array = Application.application.frameEsquerdo.getChildren();
	//var componenteFrameEsquerdo:Object;
	var i:Number;
	
	for (i = 0; i < childrenFrameEsquerdo.length; i++)
	{
		if (childrenFrameEsquerdo[i] is PainelEsquerdo)
		{
			var childrenPainelEsquerdo:Array = (PainelEsquerdo)(childrenFrameEsquerdo[i]).getChildren();
			var j:Number;
			
			var nroVeiculosNoPatioHoje:Number;
			var nroBaixas:Number;
			//var arrecadacaoHoje:Number;

			for (j = 0; j < childrenPainelEsquerdo.length; j++)
			{
				if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelCarrosNoPatioAgoraHoje")
				{
					nroVeiculosNoPatioHoje = obterNroVeiculosNoPatioHoje(forceGet);
					(Label)(childrenPainelEsquerdo[j]).text = nroVeiculosNoPatioHoje.toString();
				}
				
				else if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelBaixasHoje")
				{
					nroBaixas = obterNroBaixas(forceGet);
					(Label)(childrenPainelEsquerdo[j]).text = nroBaixas.toString();
				}
				
				else if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelTotalHoje")
				{
					(Label)(childrenPainelEsquerdo[j]).text = (nroBaixas + nroVeiculosNoPatioHoje).toString();
				}
				
				// Retirado a pedido do cliente: arrecadação na tela de trânsito
				
				/*
				else if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelArrecadacaoHoje")
				{
					var hoje:Date = new Date();
					hoje.setHours(0, 0, 0, 0);
					
					var amanha:Date = new Date();
					amanha.setDate(amanha.getDate() + 1);
					amanha.setHours(0, 0, 0, 0);
					
					arrecadacaoHoje = Movimentacao.getArrecadacao(hoje, amanha);
					(Label)(childrenPainelEsquerdo[j]).text = "R$ "+ arrecadacaoHoje.toString();
				}	*/			
			}
			
			for (j = 0; j < childrenPainelEsquerdo.length; j++)
			{
				if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelCarrosNoPatioAgoraHojeTexto")
				{
					(Label)(childrenPainelEsquerdo[j]).text = (nroVeiculosNoPatioHoje <= 1) ? "veículo no pátio agora" : "veículos no pátio agora";
				}
				
				else if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelBaixasHojeTexto")
				{
					(Label)(childrenPainelEsquerdo[j]).text = (nroBaixas <= 1) ? "baixa" : "baixas";
				}
				
				else if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelTotalHojeTexto")
				{
					(Label)(childrenPainelEsquerdo[j]).text = ((nroBaixas + nroVeiculosNoPatioHoje) <= 1) ? "veículo movimentado" : "veículos movimentados";
				}
				/*
				else if (childrenPainelEsquerdo[j] is Label && (Label)(childrenPainelEsquerdo[j]).id == "labelArrecadacaoHojeTexto")
				{
					(Label)(childrenPainelEsquerdo[j]).text = (arrecadacaoHoje <= 1) ? "arrecadado hoje" : "arrecadados hoje";
				}
				*/
			}
			
			break;
		}
	}
}

public function mostrarPainelSenha(escopo:String):void
{
	painelSenha = new PainelSenha();
	Application.application.addChild(painelSenha);
	painelSenha.setStyle("horizontalCenter", 0);
	painelSenha.setStyle("verticalCenter", 0);
	painelSenha.addEventListener(CloseEvent.CLOSE, fecharPainelSenha);
	painelSenha.escopo = escopo;
	desabilitarAplicacaoExceto(painelSenha);
}

public function fecharPainelSenha(event:CloseEvent):void
{
	Application.application.removeChild(painelSenha);
	habilitarAplicacao();	
}

public function verificarEscape(event:KeyboardEvent):void
{	
	if (event.keyCode != Keyboard.ESCAPE)
		return;
	
	var children:Array = Application.application.getChildren();
	var janela:Object = children.pop();
		
	if(janela is TitleWindow)
	{
		(TitleWindow)(janela).dispatchEvent(new CloseEvent(Event.CLOSE));
	}
}

public function mostrarPainelRelatorios():void
{
	painelRelatorios = new PainelRelatorios();
	Application.application.addChild(painelRelatorios);
	painelRelatorios.setStyle("horizontalCenter", 0);
	painelRelatorios.setStyle("verticalCenter", 0);
	painelRelatorios.addEventListener(CloseEvent.CLOSE, fecharPainelRelatorios);
	painelRelatorios.setFocus();
	desabilitarAplicacaoExceto(painelRelatorios);
}

public function fecharPainelRelatorios(event:CloseEvent):void
{
	Application.application.removeChild(painelRelatorios);
	habilitarAplicacao();	
}

public function verificarPatio():void
{
	var nroVeiculosDeOutroDia:Number = Movimentacao.nroVeiculosDeOutroDiaNoPatio();
	
	if (nroVeiculosDeOutroDia == 0)
		return;
		
	var stringAlerta:String = 
			((nroVeiculosDeOutroDia == 1) ? "Foi detectado " : "Foram detectados ") +  
			 nroVeiculosDeOutroDia + " " + 
			((nroVeiculosDeOutroDia == 1) ? "veículo movimentado " : "veículos movimentados ") + 
			((nroVeiculosDeOutroDia == 1) ? "outro dia" : "outro(s) dia(s)") + 
			" mas que " + 
			((nroVeiculosDeOutroDia == 1) ? "permanece registrado" : " permanecem registrados") + 
			" como estando no pátio. " + 
			"\nO sistema tentará corrigir este problema imediatamente.";
	
	Alert.show(stringAlerta, "Erro de inconsistência nos dados", 4, null, fInterna);
			
	function fInterna(event:CloseEvent):void
	{		
		Application.application.timerMensagemAguarde.stop();
		Application.application.mensagemAguarde.visible = true;
		Application.application.timerMensagemAguarde.addEventListener(TimerEvent.TIMER, Application.application.telaTransito.esvaziarPatioCorrecao);
		Application.application.timerMensagemAguarde.start();
	}
}

public function obterNroVeiculosNoPatioHoje(forceGet:Boolean):Number
{
	if (Utils.getStringHojeSemHorario() != Application.application.hoje || forceGet)
	{
		Application.application.nroVeiculosNoPatioHoje = Veiculo.nroVeiculosNoPatioHoje();	
	}
	
	return Application.application.nroVeiculosNoPatioHoje;
}

public function obterNroBaixas(forceGet:Boolean):Number
{
	if (Utils.getStringHojeSemHorario() != Application.application.hoje || forceGet)
	{
		Application.application.nroBaixas = Veiculo.nroBaixasHoje();	
	}
	
	return Application.application.nroBaixas;
}
//
//public function carregarPlacasDeComprovantes():void
//{
//	var comprovantes:Array = Application.application.telaTransito.comprovantesImpressos();
//	var comprovantesDataProvider:Array = new Array();
//	var dadosComprov:Array = new Array();
//	
//	for each (var comprovante:File in comprovantes)
//	{
//		if (comprovante.name == "comprovante.rtf")
//			continue;
//		
//		dadosComprov = comprovante.name.split("_");
//		
//		if (dadosComprov.length < 6)
//			continue;
//		
//		placasDeComprovantes.push(dadosComprov[1].toString());
//	}
//}
