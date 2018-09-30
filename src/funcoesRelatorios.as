// ActionScript file

import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.controls.DateChooser;
import mx.core.Application;
import mx.events.CloseEvent;

include "modeloDeRelatorio.as";
include "modeloDeResumoDeRelatorio.as";


public function initPainelRelatorio():void
{
	inicio.dayNames = 
	termino.dayNames = Application.application.nomesDeDias;
	
	inicio.monthNames =
	termino.monthNames = Application.application.nomesDeMeses;
	
	inicio.selectedDate =
	termino.selectedDate = new Date();
	
	labelInicio.text =
	labelTermino.text = Utils.dataFormatadaSemHorario(Utils.getStringInstante(inicio.selectedDate));
}

public function mudarLabelData(dC:DateChooser):void
{
	var texto:String = Utils.dataFormatadaSemHorario(Utils.getStringInstante(dC.selectedDate));
	
	if (dC.id == "inicio")
		labelInicio.text = texto;
		
	else if (dC.id == "termino")
		labelTermino.text = texto;

}

public function salvarRelatorio():void
{	
	
	if (Veiculo.nroVeiculosNoPatioPeriodo(inicio.selectedDate, termino.selectedDate) != 0)
	{
		Alert.show("Um ou mais veículos movimentados no período especificado ainda está/estão no pátio. Efetue sua baixa e tente novamente.", "Veículo(s) no pátio");
		return;
	}
	
	if (inicio.selectedDate.time > termino.selectedDate.time)
	{
		Alert.show("A data de início da abrangência deve ser anterior à de término.", "Datas inválidas");
		return;
	}
	
	if (Movimentacao.nroVeiculosPeriodo(inicio.selectedDate, termino.selectedDate) == 0)
	{
		Alert.show("Não há movimentações registradas no período especificado.", "Não há movimentações");
		return;
	}
	
	var pathAlvo:File = File.documentsDirectory;
	pathAlvo.addEventListener(Event.SELECT, fInterna);
	
	var painelRel:PainelRelatorios = this;
	
	try
	{
		pathAlvo.browseForSave("Salvar relatório como...");
		/*var filtro:FileFilter = new FileFilter("Formato Rich Text (*.rtf)", "*.rtf");
		pathAlvo.browse([filtro]);*/
	} 
	
	catch (erro:Error) {
		Alert.show("Falha ao selecionar caminho para o relatório: " + erro.message, "Erro");
	}
	
	function fImprimirResumo(event:CloseEvent):void
	{
		if (event.detail == Alert.YES)			
				Application.application.imprimirResumoDeRelatorio();
	}
	
	function fInterna(event:Event):void
	{		
		var relatorioArquivo:File = event.target as File;
		
		if (relatorioArquivo.extension != "rtf")
			relatorioArquivo.nativePath += ".rtf"
			
		var relatorioStream:FileStream = new FileStream();
		relatorioStream.open(relatorioArquivo, FileMode.WRITE);
		
		painelRel.visible = false;
		
		/*
		var mensagem:CanvasAguarde = new CanvasAguarde();
		mensagem.setStyle("horizontalCenter", 0);
		mensagem.setStyle("verticalCenter", 0);
		Application.application.addChild(mensagem);
		Application.application.desabilitarAplicacaoExceto(mensagem);*/
		
		Application.application.mensagemAguarde.visible = true;
		var timer:Timer = new Timer(100);
		timer.addEventListener(TimerEvent.TIMER, interna);
		timer.start();
		
		
		function interna(event:TimerEvent):void
		{
			timer.stop();
			var relatorioPronto:String = prepararRelatorio();
					
			relatorioStream.writeMultiByte(relatorioPronto, "iso-8859-1");
			relatorioStream.close();
			
			painelRel.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			Application.application.habilitarAplicacao();
			
			Application.application.mensagemAguarde.visible = false;
			
			Alert.show("Relatório salvo com sucesso. Gostaria de imprimir um resumo?", 
			"Relatório salvo", 
			Alert.YES|Alert.NO, 
			null, 
			fImprimirResumo
			);			
		}
		
	}	
}

public function prepararRelatorio():String
{	
	var dataInicio:Date = inicio.selectedDate;
	var dataTermino:Date = termino.selectedDate;
	
	var isRelatorioDia:Boolean = (dataInicio.time == dataTermino.time);
	
	// Vars para substituição dos flags na string do relatório:
	
	var abrangencia:String = Utils.dataFormatadaSemHorario(Utils.getStringInstante(dataInicio));	
	if (!isRelatorioDia)
		abrangencia += " - " + Utils.dataFormatadaSemHorario(Utils.getStringDia(dataTermino));
			
	var nroMovimentados:String = Movimentacao.nroVeiculosPeriodo(dataInicio, dataTermino).toString();
	
	var nroIsentos:String = Movimentacao.nroVeiculosIsentosPeriodo(dataInicio, dataTermino).toString();
	
	var nroPagantes:String = (Number(nroMovimentados) - Number(nroIsentos)).toString();
	var arrPagantesNumber:Number = Movimentacao.getArrecadacao(dataInicio, dataTermino);
	var arrPagantes:String =  "R$ " + Utils.formatarDinheiro(Movimentacao.getArrecadacao(dataInicio, dataTermino).toString());
	
	var tarifa:String = "R$ " + Utils.formatarDinheiro((arrPagantesNumber/Number(nroPagantes)).toString());

	var nroComCredito:String = Movimentacao.nroVeiculosMovimentadosComCreditoPeriodo(dataInicio, dataTermino).toString();	
	var nroSemCredito:String = (Number(nroPagantes) - Number(nroComCredito)).toString();
	
	var nroCobrEntrada:String = Movimentacao.nroVeiculosCobrancaNaEntradaPeriodo(dataInicio, dataTermino).toString();
	var arrCobrEntradaNumber:String = Movimentacao.getArrecadacaoEntradas(dataInicio, dataTermino).toString();
	var arrCobrEntrada:String = "R$ " + Utils.formatarDinheiro(Movimentacao.getArrecadacaoEntradas(dataInicio, dataTermino).toString());
	
	var nroCobrSaida:String = (Number(nroSemCredito) - Number(nroCobrEntrada)).toString();
	var arrCobrSaida:String = (Number(arrPagantesNumber) - Number(arrCobrEntradaNumber)).toString();	
	
	var creditoConcedido:String = "RS " + Utils.formatarDinheiro(Movimentacao.getCreditoDistribuido(dataInicio, dataTermino).toString());
	var creditoDeduzido:String = "RS " + Utils.formatarDinheiro(Movimentacao.getCreditoDeduzido(dataInicio, dataTermino).toString());
	
	var timestampPrimeiraEntrada:String = Movimentacao.getTPrimeiraEntrada(dataInicio);
	var timestampUltimaSaida:String = Movimentacao.getTUltimaSaida(dataTermino)
	
	var tPrimeiraEntrada:String = Utils.dataFormatada(timestampPrimeiraEntrada);
	var tUltimaSaida:String = Utils.dataFormatada(timestampUltimaSaida);
	
	var primeiraEntrada:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	primeiraEntrada.obterDadosPorTimestamp(timestampPrimeiraEntrada);
	
	var ultimaSaida:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	ultimaSaida.obterDadosPorTimestamp(timestampUltimaSaida);
	
	var vPrimeiraEntrada:String = primeiraEntrada.getVeiculoAssociado().getPlaca()
	
	var marcaVeiculoPrimeiraEntrada:String = primeiraEntrada.getVeiculoAssociado().getNomeMarca()
	var modeloVeiculoPrimeiraEntrada:String = primeiraEntrada.getVeiculoAssociado().getNomeModelo();
	
	if (	marcaVeiculoPrimeiraEntrada != "Outras" 
		&& 	marcaVeiculoPrimeiraEntrada != "Outra"
		&&	modeloVeiculoPrimeiraEntrada != "Outro"
		&&	modeloVeiculoPrimeiraEntrada != "Outros"
		)
	{
		vPrimeiraEntrada += " (" + marcaVeiculoPrimeiraEntrada + " " + modeloVeiculoPrimeiraEntrada + ")";
	}
	
	var vUltimaSaida:String = ultimaSaida.getVeiculoAssociado().getPlaca();
	
	var marcaVeiculoUltimaSaida:String = ultimaSaida.getVeiculoAssociado().getNomeMarca()
	var modeloVeiculoUltimaSaida:String = ultimaSaida.getVeiculoAssociado().getNomeModelo();
	
	if (	marcaVeiculoUltimaSaida != "Outras" 
		&& 	marcaVeiculoUltimaSaida != "Outra"
		&&	modeloVeiculoUltimaSaida != "Outro"
		&&	modeloVeiculoUltimaSaida != "Outros"
		)
	{
		vUltimaSaida += " (" + marcaVeiculoUltimaSaida + " " + modeloVeiculoUltimaSaida + ")";
	}
	
	var nroNovos:String = Movimentacao.nroVeiculosNovatosPeriodo(dataInicio, dataTermino).toString();
		
	// Substituições na string do relatório:
	
	var relatorioPronto:String = relatorio;
	Application.application.resumoDeRelatorio = modeloResumoDeRelatorio;
	
	var regexPattern:RegExp = /%timestamp%/g;	
	relatorioPronto = relatorioPronto.replace(regexPattern, Utils.dataFormatadaSemHorario(Utils.getStringAgora(false)));
	
	regexPattern = /%abrangencia%/g;	
	relatorioPronto = relatorioPronto.replace(regexPattern, abrangencia);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, abrangencia);
	
	regexPattern = /%tarifa%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, tarifa);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, tarifa);
	
	regexPattern = /%nroMovimentados%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroMovimentados);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroMovimentados);
	
	regexPattern = /%nroIsentos%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroIsentos);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroIsentos);
	
	regexPattern = /%nroPagantes%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroPagantes);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroPagantes);
	
	regexPattern = /%nroCobrEntrada%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroCobrEntrada);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroCobrEntrada);
	
	regexPattern = /%arrPagantes%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, arrPagantes);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, arrPagantes);
	
	regexPattern = /%nroPagantes%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroPagantes);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroPagantes);
	
	regexPattern = /%nroComCredito%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroComCredito);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroComCredito);
	
	regexPattern = /%nroSemCredito%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroSemCredito);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroSemCredito);
	
	regexPattern = /%nroCobrSaida%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroCobrSaida);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroCobrSaida);
	
	regexPattern = /%arrCobrEntrada%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, arrCobrEntrada);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, arrCobrEntrada);
	
	regexPattern = /%arrCobrSaida%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, arrCobrSaida);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, arrCobrSaida);
	
	regexPattern = /%tPrimeiraEntrada%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, tPrimeiraEntrada);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, tPrimeiraEntrada);
	
	regexPattern = /%tUltimaSaida%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, tUltimaSaida);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, tUltimaSaida);
	
	regexPattern = /%vPrimeiraEntrada%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, vPrimeiraEntrada);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, vPrimeiraEntrada);
	
	regexPattern = /%vUltimaSaida%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, vUltimaSaida);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, vUltimaSaida);
	
	regexPattern = /%nroNovos%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, nroNovos);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, nroNovos);
	
	regexPattern = /%creditoConcedido%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, creditoConcedido);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, creditoConcedido);
	
	regexPattern = /%creditoDeduzido%/g;
	relatorioPronto = relatorioPronto.replace(regexPattern, creditoDeduzido);
	Application.application.resumoDeRelatorio = Application.application.resumoDeRelatorio.replace(regexPattern, creditoDeduzido);
	
	var m:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	var timestamps:Array = Movimentacao.timestampsPeriodo(dataInicio, dataTermino);
	
	for (var i:Number = 0; i < timestamps.length; i += 2)
	{
		m.obterDadosPorTimestamp(timestamps[i]);
		
		var mCod:String = m.getId();
		var mPlaca:String = m.getVeiculoAssociado().getPlaca();
		var mMarca:String = m.getVeiculoAssociado().getNomeMarca();		
		var mModelo:String = m.getVeiculoAssociado().getNomeModelo();		
		var mCor:String = m.getVeiculoAssociado().getNomeCor();
		var mEntrada:String = Utils.dataFormatada(m.getT());
		
		var mTipoCobranca:String = "";
		
		if (m.getVeiculoAssociado().getIsento() == "1")
			mTipoCobranca = "I";
		
		else if (m.getCobrancaNaEntrada() && m.creditoFoiDeduzido())
			mTipoCobranca = "E/CC";
			
		else if (m.getCobrancaNaEntrada() && m.getVeiculoAssociado().getIsento() == "0")
			mTipoCobranca = "E/SC";
			
		else if (!m.getCobrancaNaEntrada() && m.getVeiculoAssociado().getIsento() == "0")
			mTipoCobranca = "S/SC";
			
		else
			mTipoCobranca = "S/SC";
			
		
		regexPattern = /%mCod%/g;
		var linhaTabela:String = linhaTabelaMovimentacoes.replace(regexPattern, mCod);
		
		regexPattern = /%mPlaca%/g;
		linhaTabela = linhaTabela.replace(regexPattern, mPlaca);
		
		regexPattern = /%mMarca%/g;
		linhaTabela = linhaTabela.replace(regexPattern, mMarca);
		
		regexPattern = /%mModelo%/g;
		linhaTabela = linhaTabela.replace(regexPattern, mModelo);
		
		regexPattern = /%mCor%/g;
		linhaTabela = linhaTabela.replace(regexPattern, mCor);
		
		regexPattern = /%mEntrada%/g;
		linhaTabela = linhaTabela.replace(regexPattern, mEntrada);
		
		regexPattern = /%mTipoCobranca%/g;
		linhaTabela = linhaTabela.replace(regexPattern, mTipoCobranca);
		
		m.obterDadosPorTimestamp(timestamps[(i + 1)]);		
		
		if (m is Object && m.getT() is Object)
		{
			var mSaida:String = Utils.dataFormatada(m.getT());
			regexPattern = /%mSaida%/g;
			linhaTabela = linhaTabela.replace(regexPattern, mSaida);
		}
		
		relatorioPronto += linhaTabela;
		
	} 
	
	relatorioPronto += "}";
	
	return relatorioPronto;	
}