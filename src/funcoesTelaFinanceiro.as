// ActionScript file

import com.spiel.Conexao;
import com.spiel.Movimentacao;
import com.spiel.Utils;

import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;

import mx.controls.Alert;
import mx.core.Application;
import mx.managers.CursorManager;

public function initFinanceiro():void
{
	
	dataInicio.showToday =
	dataTermino.showToday = true;
	
	dataInicio.dayNames = 
	dataTermino.dayNames = Application.application.nomesDeDias;
	
	dataInicio.monthNames =
	dataTermino.monthNames = Application.application.nomesDeMeses;
	
	dataTermino.selectedDate = new Date();
	dataInicio.selectedDate = new Date();

	tratarChangeAccordion();
}

public function atualizarNumeros():void
{
	dataInicio.showToday =
	dataTermino.showToday = false;
	
	var inicio:Date = dataInicio.selectedDate;
	var termino:Date = dataTermino.selectedDate;
	
	if (inicio.time > termino.time)
	{
		textoInfoControles.setStyle("color", 0xff0000);
		textoInfoControles.text = "Erro: a data de ínicio da análise deve ser anterior à data de término.";
		return;
	}
	
	textoInfoControles.clearStyle("color");
	textoInfoControles.text = "Use os controles ao lado para selecionar um período de análise e mudar automaticamente os números acima.";
	
	labelInicioPainel.text = Utils.dataFormatadaSemHorario(Utils.getStringInstante(inicio));	
	labelTerminoPainel.text = Utils.dataFormatadaSemHorario(Utils.getStringInstante(termino));
	
	if (inicio.time == termino.time)
	{
		labelA.visible =
		labelTermino.visible = false;
		
		labelDeEm.text = "Houve, em";
		labelInicio.text = labelInicioPainel.text + ",";
	}
	
	else
	{
		labelA.visible =
		labelTermino.visible = true;
		
		labelTermino.text = labelTerminoPainel.text + ", ";
		labelInicio.text = labelInicioPainel.text;
		
		labelDeEm.text = "Houve, de";
	}
	
	
	// Veículos movimentados
	var nroVeiculosMovimentados:Number = Movimentacao.nroVeiculosPeriodo(inicio, termino);
	labelNroVeiculosMovimentados.text = nroVeiculosMovimentados.toString();
	labelVeiculosMovimentados.label = (nroVeiculosMovimentados <= 1) ? "movimentação" : "movimentações";
	
	// Isentos:
	var nroVeiculosIsentos:Number = Movimentacao.nroVeiculosIsentosPeriodo(inicio, termino);
	labelNroVeiculosIsentos.text = nroVeiculosIsentos.toString();
	labelVeiculosIsentos.label = (nroVeiculosIsentos <= 1) ? "veículo isento" : "veículos isentos";
	
	// Pagantes:
	var nroVeiculosPagantes:Number = nroVeiculosMovimentados - nroVeiculosIsentos;
	labelNroVeiculosPagantes.text = nroVeiculosPagantes.toString();
	labelVeiculosPagantes.label = (nroVeiculosPagantes <= 1) ? "veículo pagante" : "veículos pagantes";
	
	// Com crédito:
	var nroVeiculosComCredito:Number = Movimentacao.nroVeiculosMovimentadosComCreditoPeriodo(inicio, termino);
	labelNroVeiculosComCredito.text = nroVeiculosComCredito.toString();
	
	// Sem crédito:
	var nroVeiculosSemCredito:Number = nroVeiculosPagantes - nroVeiculosComCredito;
	labelNroVeiculosSemCredito.text = nroVeiculosSemCredito.toString();
	
	// Cobr. na entrada:
	var nroVeiculosCobrancaNaEntrada:Number = Movimentacao.nroVeiculosCobrancaNaEntradaPeriodo(inicio, termino);
	labelNroVeiculosCobrancaNaEntrada.text = nroVeiculosCobrancaNaEntrada.toString();
	
	// Cobr. na saída:
	var nroVeiculosCobrancaNaSaida:Number = nroVeiculosSemCredito - nroVeiculosCobrancaNaEntrada;
	labelNroVeiculosCobrancaNaSaida.text = nroVeiculosCobrancaNaSaida.toString();
	
	// Arrecadação:		
	var arrecadacao:Number = Movimentacao.getArrecadacao(inicio, termino);
	labelNroArrecadados.text = Utils.formatarDinheiro(arrecadacao.toString());
	labelArrecadados.label = (arrecadacao <= 1) ? "foi arrecadado" : "foram arrecadados";
	
	// Crédito distribuído:
	var creditoDistribuido:Number = Movimentacao.getCreditoDistribuido(inicio, termino);
	labelNroCreditosDistribuidos.text = Utils.formatarDinheiro(creditoDistribuido.toString());
	labelCreditosDistribuidos.label = (creditoDistribuido <= 1) ? "foi distribuído em créditos" : "foram distribuídos em créditos";
	
	// Crédito deduzido:
	var creditoDeduzido:Number = Movimentacao.getCreditoDeduzido(inicio, termino);
	labelNroCreditosDeduzidos.text = Utils.formatarDinheiro(creditoDeduzido.toString());
	labelCreditosDeduzidos.label = (creditoDeduzido <= 1) ? "foi deduzido dos créditos" : "foram deduzidos dos créditos";
		
}

public function initGrafico():void
{
	
	dataInicioG.showToday =
	dataTerminoG.showToday = true;
	
	dataInicioG.dayNames = 
	dataTerminoG.dayNames = Application.application.nomesDeDias;
	
	dataInicioG.monthNames =
	dataTerminoG.monthNames = Application.application.nomesDeMeses;
	
	dataInicioG.selectedDate = Utils.getDate(Movimentacao.getMinT());
	dataTerminoG.selectedDate = new Date();
	
	povoarGrafico();
}

public function povoarGrafico():void
{
	// Atualizando as labels dos controles de calendário:
	labelInicioPainelG.text = Utils.dataFormatadaSemHorario(Utils.getStringInstante(dataInicioG.selectedDate));
	labelTerminoPainelG.text = Utils.dataFormatadaSemHorario(Utils.getStringInstante(dataTerminoG.selectedDate));
	
	var dataProvider:Array;
	var arrecadacao:Number = 0;			 						
	var comandoArrecadacao:String =
		"select distinct substr(t, 1, 8) as DIA, " + 
		"count(*) as NMOVS " + 
		"from movimentacoes " + 
		"where codigo = 1 " + 
		"and T BETWEEN '" + Utils.getStringDia(dataInicioG.selectedDate) + "' AND '" + Utils.getStringInstantePreencherCom9s(dataTerminoG.selectedDate) + "' " +
		"group by DIA;"; //Alert.show(comandoArrecadacao);
	
	var s:SQLStatement = new SQLStatement();	
	s.text = comandoArrecadacao;
	s.sqlConnection = new Conexao();
	s.addEventListener(SQLEvent.RESULT, tratadora);
	s.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
				
	var r:SQLResult;
	
	try 
	{
		s.execute();
	}
	
	catch (erro:Error)
	{
		Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + erro.message);
	}
	
	s.sqlConnection.close();
	grafico.dataProvider = dataProvider;
	
	function tratadora(event:SQLEvent):void
	{
		r = s.getResult();
		
		if (r is Object && r.data is Object && r.data[0].DIA is Object)
		{
			dataProvider = new Array();
			
			for (var i:Number = 0; i < r.data.length; i++)
			{
				var tupla:Object = new Object();
				tupla.dia = Utils.dataFormatadaSemHorario(r.data[i].DIA.toString());
				tupla.nroMovimentacoes = Number(r.data[i].NMOVS.toString());
				dataProvider.push(tupla);
			}		
		}
	}
	
	function tratadoraErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao calcular a arrecadação em um intervalo de tempo: " + event.error.details);
	}
}

public function tratarChangeAccordion():void
{
	switch (accordionFinanceiro.selectedIndex)
	{
		case 0:
		
			if (canvasNumeros.initialized)
				atualizarNumeros();
				
			break;
			
		case 1:
			if (canvasGrafico.initialized)
				initGrafico();
				
			break;
	}	
}