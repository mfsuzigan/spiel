// ActionScript file
import com.spiel.Cor;
import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.events.ValidationResultEvent;
import mx.core.Application;

[Bindable]
public var timerCanvasMensagem:Timer = new Timer(8000, 1);

[Bindable]
public var timer:Timer = new Timer(45, 1);


public function toggleVeiculoIsento(event:Event):void
{
	checkboxCobrancaNaEntrada.enabled = !checkboxVeiculoIsento.selected;
	checkboxCobrancaNaEntrada.selected = !checkboxVeiculoIsento.selected;
	
	inputCredito.enabled = !checkboxVeiculoIsento.selected;
	inputCredito.text = (checkboxVeiculoIsento.selected) ? "0,00" : inputCredito.text;
	
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
	
	if (inputModelo.text == "")
	{
		Alert.show("Você deve escolher o modelo do veículo.", "Erro");
		return;
	}
	
	if (inputCor.text == "")
	{
		Alert.show("Você deve escolher a cor do veículo.", "Erro");
		return;
	}
	
	if (textoModeloStatus.text == "Modelo não encontrado:")
	{
		Alert.show("O modelo de veículo inserido não foi encontrado.", "Erro");
		return;
	}
	
	if (textoCorStatus.text == "Cor não encontrada:")
	{
		Alert.show("A cor de veículo inserida não foi encontrada.", "Erro");
		return;
	}
	

	if (validadorInputCredito.validate().type == ValidationResultEvent.VALID)
	{
		Application.application.mensagemAguarde.visible = true;
		
		timer.addEventListener(TimerEvent.TIMER, inserirVeiculo);
		timer.start();
	}
}

public function creditoValidado(valor:String):String
{
	return valor.replace(",", ".");
}

public function inserirVeiculo(event:TimerEvent):void
{
	var v:Veiculo = new Veiculo();
	v.setPlaca(inputVeiculo.text);
	
	v.setIdModelo(Veiculo.getIdModelo(inputModelo.text));
	v.setIdCor(Cor.getCodigo(inputCor.text));
	v.setCredito(creditoValidado(inputCredito.text));
	v.setIsento(checkboxVeiculoIsento.selected ? "1" : "0");
	v.inserir();
	
	var cadastroDoVeiculo:Movimentacao = new Movimentacao(false, v, 0, -1, checkboxCobrancaNaEntrada.selected);
	cadastroDoVeiculo.registrar();
	
	var primeiraEntrada:Movimentacao = new Movimentacao(false, v, 1, 0, checkboxCobrancaNaEntrada.selected);
	var registroBemSucedido:Boolean = primeiraEntrada.registrar();
	
	if (registroBemSucedido)
	{	
		Application.application.mensagemAguarde.visible = false;
		/*if (checkboxCobrancaNaEntrada.selected)
		{
			canvasEfetuarCobranca.visible = true;
			labelEfetuarCobranca.text += Configuracoes.getTarifa();
		}
		*/
		
		var nomeCor:String = v.getNomeCor();
		
		labelDesignacaoVeiculo.text = 	v.getNomeMarca() + " " 
									+ 	v.getNomeModelo() + " " 
									+ 	((nomeCor != "Outra") ? nomeCor.toLowerCase() + " " : "") 
									+	"(" + v.getPlaca() + ") ";
		
		if (nomeCor == "Prata")
		{
			labelDesignacaoVeiculo.setStyle("color", Cor.getCodigo("Cinza"));
		}
									
		else if (nomeCor != "Branco" && nomeCor != "Outra")
		{	
			labelDesignacaoVeiculo.setStyle("color", Cor.getCodigo(nomeCor));
		}
		
		else
		{
			labelDesignacaoVeiculo.clearStyle("color");
		}
		
		labelDesignacaoMovimentacao.text = "entrou no pátio. Código: ";
		labelDesignacaoMovimentacao.text += Movimentacao.getIdUltimaMovimentacao(v.getPlaca()).toString() + ".";
		//labelDesignacaoMovimentacao.text += "(" + Utils.dataFormatada(primeiraEntrada.getT()) + ")";
		
		labelInstanteMensagem.text = Utils.dataFormatada(primeiraEntrada.getT()).substr(11, 8);
		labelDataMensagem.text = Utils.dataFormatada(primeiraEntrada.getT()).substr(0, 10);
		
		mostrarCanvasMensagem	(	(checkboxCobrancaNaEntrada.selected && v.getIsento() != "1"), 
									primeiraEntrada.creditoFoiDeduzido(),
									(!primeiraEntrada.creditoFoiDeduzido() && v.isCreditoInsuficiente())
								);
		
		inputVeiculo.text = "";
		escondeAccordionDireito();
		inputVeiculo.dispatchEvent(new Event(Event.CHANGE));
		inputVeiculo.setFocus();
		
		Application.application.nroVeiculosNoPatioHoje++;
		atualizarEstatisticas(false);
		//tabelaHistorico.povoar(null, null, null);
		//tabelaHistorico.dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_END));
		tratarChangeEventData(new Event(Event.CHANGE));
		imprimirComprovante(primeiraEntrada, false);
		
		/*
		habilitarAplicacao();
		Application.application.removeChild(mensagem);
		*/
	}
}
