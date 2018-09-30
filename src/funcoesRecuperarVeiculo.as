// ActionScript file
import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.events.TimerEvent;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;

public function processarInput():void
{
	// Decide se o input é uma placa ou número de entrada
	// de veículo; modifica a mensagem na tela;
	// dá sequência ao processo de input.
	
	//escondeAccordionDireito();
	
	var veiculo:Veiculo;	
	var expInteiro:RegExp = /^\d+$/;
	var placaVeiculoAssociado:String
	
	botaoEntrada.enabled = false;
	botaoSaida.enabled = false;
	
	textoStatusVeiculo.visible = true;
	gridMovimentacaoBloqueada.visible = false;
	
	// Para melhorar o desempenho:
	var inputV:String = inputVeiculo.text;
	
	if (expInteiro.test(inputV))
	{
		// O input é um inteiro: o veículo existe
				
		if (Movimentacao.existeEntrada(inputV))
		{
			veiculo = Movimentacao.getVeiculoAssociado(inputV);
			placaVeiculoAssociado = veiculo.getPlaca();
			
			var movExaminada:Movimentacao = new Movimentacao(true, null, 0, 0, false);
			movExaminada.obterDados(inputV);
			
			if 	(	inputV == Movimentacao.getIdUltimaMovimentacao(placaVeiculoAssociado).toString() 
				&&	Movimentacao.getCodigoUltimaMovimentacao(placaVeiculoAssociado) == 1
				)
			{
				// O número entrado é de uma movimentação de entrada de veículo válida
				
				if (Application.application.modoSomenteEntradas)
				{
					textoStatusVeiculo.setStyle("color", 0x2c7313);
					textoStatusVeiculo.text = "Veículo no pátio\nDesative o modo Somente Entradas para efetuar a saída";
					mudarCorInputVeiculo("cinza");
					inputVeiculo.setFocus();
					
					if (accordionRegistrarVeiculo.visible || accordionVeiculoRegistrado.visible)
							
						escondeAccordionDireito();
						
					// Limpar anotações associadas:
					limparPopupAnotacao();
				}
				
				else 
				{				
					mudarCorInputVeiculo("cinza");
					textoStatusVeiculo.setStyle("color", 0x2c7313);	
					textoStatusVeiculo.text = "Veículo no pátio";
					
					botaoSaida.enabled = true;				
					
					povoarPainelVeiculoRegistrado(veiculo, 1);
					
					mostraAccordionDireito(veiculo);
				}
			}
			
			else
			{
				// O número entrado é de uma movimentação de entrada já "baixada"
				
				mudarCorInputVeiculo("cinza");
				textoStatusVeiculo.setStyle("color", 0xff0000);
				textoStatusVeiculo.text = "Nenhum veículo no pátio com tal código de entrada";
				mudarCorInputVeiculo("vermelho");
				inputVeiculo.setFocus();
				
				escondeAccordionDireito();
			}
		}	
		
		else
		{
			// O número entrada não corresponde a uma entrada de veículo válida
			
			textoStatusVeiculo.setStyle("color", 0xff0000);
			textoStatusVeiculo.text = "Nenhum veículo no pátio com tal código de entrada";
			mudarCorInputVeiculo("vermelho");
			inputVeiculo.setFocus();
			
			escondeAccordionDireito();
		}
		
		// Ver se há anotações associadas:
		popupAnotacao();
	}
	
	else if (Veiculo.isPlaca(inputV))
	{
		// O input é uma placa de veículo válida
		
		veiculo = new Veiculo();
		var veiculoExiste:Boolean = veiculo.obterDados(inputV);
		var veiculoJaEntrouHoje:Boolean = veiculo.jaEntrouHoje();
		placaVeiculoAssociado = veiculo.getPlaca();
			
		mudarCorInputVeiculo("cinza");	
		
		var codigoUltMov:Number = Movimentacao.getCodigoUltimaMovimentacao(placaVeiculoAssociado);
					
		if (!veiculoExiste)
		{
			// Não existe veículo registrado sob a placa entrada
			
			textoStatusVeiculo.setStyle("color", 0xf69281);
			textoStatusVeiculo.text = "Veículo não registrado";
			
			mostraAccordionDireito(null);
		}
		
		else if (veiculoJaEntrouHoje && codigoUltMov == Movimentacao.COD_SAIDA_NUMBER)
		{
			// o veículo já sofreu movimentação hoje
			
			textoStatusVeiculo.visible = false;
			gridMovimentacaoBloqueada.visible = true;
		}
		
		else
		{
			// O veículo com tal placa existe
			
			mudarCorInputVeiculo("cinza");	
			
			if (codigoUltMov == Movimentacao.COD_ENTRADA_NUMBER)
			{
				if (Application.application.modoSomenteEntradas)
				{
					textoStatusVeiculo.setStyle("color", 0x2c7313);
					textoStatusVeiculo.text = "Veículo no pátio\nDesative o modo Somente Entradas para efetuar a saída";
					mudarCorInputVeiculo("cinza");
					inputVeiculo.setFocus();
					
					if (accordionRegistrarVeiculo.visible || accordionVeiculoRegistrado.visible)
							
						escondeAccordionDireito();
						
					// Limpar anotações associadas:
					limparPopupAnotacao();
				}
				
				else
				{
					povoarPainelVeiculoRegistrado(veiculo, codigoUltMov);
					textoStatusVeiculo.setStyle("color", 0x2c7313);	
					textoStatusVeiculo.text = "Veículo no pátio";
					
					botaoSaida.enabled = true;					
					mostraAccordionDireito(veiculo);
				}
			}
			
			else if (codigoUltMov == Movimentacao.COD_SAIDA_NUMBER || codigoUltMov == Movimentacao.COD_REGISTRO_NUMBER)
			{
				povoarPainelVeiculoRegistrado(veiculo, codigoUltMov);
				textoStatusVeiculo.setStyle("color", 0x135073);	
				textoStatusVeiculo.text = "Veículo fora do pátio";
				
				botaoEntrada.enabled = true;
				mostraAccordionDireito(veiculo);
				
			}
			
		}
		
		// Ver se há anotações associadas:
		popupAnotacao();
	}
	
	else if (inputV == "")
	{
		textoStatusVeiculo.setStyle("color", 0x0b333c);
		textoStatusVeiculo.text = "Insira uma placa ou código de entrada de veículo";
		mudarCorInputVeiculo("cinza");
		inputVeiculo.setFocus();
		
		if (accordionRegistrarVeiculo.visible || accordionVeiculoRegistrado.visible)
				
			escondeAccordionDireito();
			
		// Limpar anotações associadas:
		limparPopupAnotacao();
	}
	
	else
	{
		textoStatusVeiculo.setStyle("color", 0xff0000);
		textoStatusVeiculo.text = "Placa ou código de entrada inválido";
		mudarCorInputVeiculo("vermelho");
		inputVeiculo.setFocus();
		
		if (accordionRegistrarVeiculo.visible || accordionVeiculoRegistrado.visible)
		
			escondeAccordionDireito();
			
		// Limpar anotações associadas:
		limparPopupAnotacao();
	}
}

public function toggleVeiculoIsentoRegistrado(event:Event):void
{
	checkboxCobrancaNaEntradaVeiculoRegistrado.enabled = !checkboxVeiculoIsentoRegistrado.selected;
	checkboxCobrancaNaEntradaVeiculoRegistrado.selected = !checkboxVeiculoIsentoRegistrado.selected;
	
}

public function povoarPainelVeiculoRegistrado(veiculo:Veiculo, codigoUltMov:Number):void
{
	labelMarca.text = veiculo.getNomeMarca();
	var tamanhoLetraMarca:Number = 36;
	
	if (labelMarca.text.length > 9)
	{
		tamanhoLetraMarca = 2 * (11 - labelMarca.text.length) + 30;
	}
	
	labelMarca.setStyle("fontSize", tamanhoLetraMarca);
	
	labelModelo.text = veiculo.getNomeModelo();
	var tamanhoLetraModelo:Number = 36;
	
	if (labelModelo.text.length > 9)
	{
		tamanhoLetraModelo = 2 * (11 - labelModelo.text.length) + 30;
	}
	
	labelModelo.setStyle("fontSize", tamanhoLetraModelo);
	
	labelPlaca.text = veiculo.getPlaca();
	
	labelOutraCor.visible = (veiculo.getNomeCor() == "Outra");
	canvasCor.setStyle("backgroundColor", Number(veiculo.getIdCor()));
	labelCor.text = veiculo.getNomeCor();
	
	checkboxVeiculoIsentoRegistrado.selected = (veiculo.getIsento() == "1");
	checkboxCobrancaNaEntradaVeiculoRegistrado.enabled = !checkboxVeiculoIsentoRegistrado.selected;
	checkboxCobrancaNaEntradaVeiculoRegistrado.selected = !checkboxVeiculoIsentoRegistrado.selected;
	
	//Tabela de movimentações para o veículo:
	
	canvasMovimentacoes.removeAllChildren();
	var tabelaMovimentacoes:TabelaMovimentacoes = new TabelaMovimentacoes();
	canvasMovimentacoes.addChild(tabelaMovimentacoes);
	tabelaMovimentacoes.povoar(veiculo.getPlaca(), null, null);
	
	tabelaMovimentacoes.adaptarAPainelDireito();
	//tabelaMovimentacoes.setStyle("horizontalAlign", 0);
	//tabelaMovimentacoes.setStyle("verticalAlign", 0);
	tabelaMovimentacoes.setStyle("top", "3");
	tabelaMovimentacoes.setStyle("bottom", "3");
	tabelaMovimentacoes.setStyle("right", "3");
	tabelaMovimentacoes.setStyle("left", "3");
	
	if (codigoUltMov.toString() == "1")
	{
		// A última movimentação do veículo foi entrada no pátio
		
		labelValorCodigoDeEntrada.text = Movimentacao.getIdUltimaMovimentacao(veiculo.getPlaca()).toString();
		canvasDadosVeiculo.setStyle("backgroundColor", 0xd1f9c3);
		canvasMovimentacoes.setStyle("backgroundColor", 0xd1f9c3);
		labelStatus.text = "No pátio";
		imagemStatusNoPatio.visible = true;
		imagemStatusForaDoPatio.visible = false;
		
		checkboxCobrancaNaEntradaVeiculoRegistrado.visible = false;
		//checkboxVeiculoIsentoRegistrado.setStyle("top", 342);
		
		botaoSaida.enabled = true;
	}
	
	else
	{
		// A última movimentação do veículo foi saída do pátio
		
		labelValorCodigoDeEntrada.text = "N/A";
		canvasDadosVeiculo.setStyle("backgroundColor", 0xc3e5f9);
		canvasMovimentacoes.setStyle("backgroundColor", 0xc3e5f9);
		labelStatus.text = "Fora do pátio";
		imagemStatusNoPatio.visible = false;
		imagemStatusForaDoPatio.visible = true;
		
		checkboxCobrancaNaEntradaVeiculoRegistrado.visible = true;
		//checkboxVeiculoIsentoRegistrado.setStyle("top", 330);
		
		botaoEntrada.enabled = true;
	}
}

public function entradaNoPatio(placa:String):void
{
	var veiculo:Veiculo = new Veiculo();
	
	if (Veiculo.isPlaca(placa))
	{
		// input: placa
		
		veiculo.obterDados(placa);
	}
	
	else
	{
		return;
	}
	
	//var movAnterior:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	//movAnterior.obterDados(Movimentacao.getIdUltimaMovimentacao(veiculo.getPlaca()).toString());
	
	var entrada:Movimentacao = new Movimentacao(false, veiculo, 1, 2, checkboxCobrancaNaEntradaVeiculoRegistrado.selected);
	var entradaBemSucedida:Boolean = entrada.registrar();
	
	if (entradaBemSucedida)
	{
		labelDesignacaoVeiculo.text = 	veiculo.getNomeMarca() + " " 
									+ 	veiculo.getNomeModelo() + " " 
									+ 	((veiculo.getNomeCor() != "Outra") ? veiculo.getNomeCor().toLowerCase() + " " : "") 
									+	"(" + veiculo.getPlaca() + ") ";
		
		if (veiculo.getNomeCor() == "Prata")
		{
			labelDesignacaoVeiculo.setStyle("color", Cor.getCodigo("Cinza"));
		}
									
		else if (veiculo.getNomeCor() != "Branco" && veiculo.getNomeCor() != "Outra")
		{	
			labelDesignacaoVeiculo.setStyle("color", Cor.getCodigo(veiculo.getNomeCor()));
		}
		
		else
		{
			labelDesignacaoVeiculo.clearStyle("color");
		}
		
		labelDesignacaoMovimentacao.text = "entrou no pátio. Código: ";
		labelDesignacaoMovimentacao.text += Movimentacao.getIdUltimaMovimentacao(veiculo.getPlaca()).toString() + " ";
		//labelDesignacaoMovimentacao.text += "(" + Utils.dataFormatada(entrada.getT()) + ")";
		
		labelInstanteMensagem.text = Utils.dataFormatada(entrada.getT()).substr(11, 8);
		labelDataMensagem.text = Utils.dataFormatada(entrada.getT()).substr(0, 10);
		
		
		mostrarCanvasMensagem	(	(checkboxCobrancaNaEntradaVeiculoRegistrado.selected && veiculo.getIsento() != "1"), 
									entrada.creditoFoiDeduzido(),
									(!entrada.creditoFoiDeduzido() && veiculo.isCreditoInsuficiente())
								);
								
		inputVeiculo.text = "";
		processarInput();	
		
		//tabelaHistorico.povoar(null, null, null);
		//tabelaHistorico.dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_END));
		tratarChangeEventData(new Event(Event.CHANGE));				
		Application.application.mensagemAguarde.visible = false;
		Application.application.nroVeiculosNoPatioHoje++;
		atualizarEstatisticas(false);
		imprimirComprovante(entrada, false);
	}
}

public function saidaDoPatio(input:String):void
{
	var veiculo:Veiculo = new Veiculo();
	
	if (Utils.isInteiro(input))
	{
		// input: nro de entrada
		
		veiculo = Movimentacao.getVeiculoAssociado(input);
	}
	
	else if (Veiculo.isPlaca(input))
	{
		// input: placa
		
		veiculo.obterDados(input);
	}
	
	else
	{
		return;
	}
	
	var movAnterior:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	movAnterior.obterDados(Movimentacao.getIdUltimaMovimentacao(veiculo.getPlaca()).toString());
	
	var saida:Movimentacao = new Movimentacao(false, veiculo, 2, 1, movAnterior.getCobrancaNaEntrada());
	var saidaBemSucedida:Boolean = saida.registrar();
	
	if (saidaBemSucedida)
	{
		labelDesignacaoVeiculo.text = 	veiculo.getNomeMarca() + " " 
									+ 	veiculo.getNomeModelo() + " " 
									+ 	((veiculo.getNomeCor() != "Outra") ? veiculo.getNomeCor().toLowerCase() + " " : "") 
									+	"(" + veiculo.getPlaca() + ") ";
		
		if (veiculo.getNomeCor() == "Prata")
		{
			labelDesignacaoVeiculo.setStyle("color", Cor.getCodigo("Cinza"));
		}
									
		else if (veiculo.getNomeCor() != "Branco" && veiculo.getNomeCor() != "Outra")
		{	
			labelDesignacaoVeiculo.setStyle("color", Cor.getCodigo(veiculo.getNomeCor()));
		}
		
		else
		{
			labelDesignacaoVeiculo.clearStyle("color");
		}
		
		labelDesignacaoMovimentacao.text = "saiu do pátio.";
		
		labelInstanteMensagem.text = Utils.dataFormatada(saida.getT()).substr(11, 8);
		labelDataMensagem.text = Utils.dataFormatada(saida.getT()).substr(0, 10);
		
		mostrarCanvasMensagem	(	(!movAnterior.getCobrancaNaEntrada() && veiculo.getIsento() != "1"), 
									saida.creditoFoiDeduzido(),
									(!saida.creditoFoiDeduzido() && veiculo.isCreditoInsuficiente())
								);
		inputVeiculo.text = "";
		processarInput();		
		
		//tabelaHistorico.povoar(null, null, null);
		//tabelaHistorico.dispatchEvent(new DataGridEvent(DataGridEvent.ITEM_EDIT_END));
		Application.application.mensagemAguarde.visible = false;
		tratarChangeEventData(new Event(Event.CHANGE));
		Application.application.nroBaixas++;
		Application.application.nroVeiculosNoPatioHoje--;
		atualizarEstatisticas(false);
	}
}

public function esvaziarPatio(event:TimerEvent):void
{	
	Application.application.telaTransito.timerMensagemAguarde.stop();
	var veiculo:Veiculo = new Veiculo();
	var placasNoPatio:Array = Movimentacao.placasDeVeiculosNoPatio();
	var movAnterior:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	var ok:Boolean = true;
	
	var nroSaidas:Number = 0;
	
	for each (var placa:String in placasNoPatio)
	{
		veiculo.obterDados(placa);
		movAnterior.obterDados(Movimentacao.getIdUltimaMovimentacao(placa).toString());
	
		var saida:Movimentacao = new Movimentacao(false, veiculo, 2, 1, movAnterior.getCobrancaNaEntrada());
		ok = ok && saida.registrar();
		nroSaidas++;
	}
	
	Application.application.mensagemAguarde.visible = false;
	
	if (ok)
	{
		mostrarCanvasMensagemGenerica	
		( "Todos os veículos saíram do pátio.",
			Utils.dataFormatada(saida.getT()).substr(11, 8), Utils.dataFormatada(saida.getT()).substr(0, 10)
		);
		
		tratarChangeEventData(new Event(Event.CHANGE));
		Application.application.nroBaixas += nroSaidas;
		Application.application.nroVeiculosNoPatioHoje = 0;
		atualizarEstatisticas(false);
	}
}

public function esvaziarPatioCorrecao(event:TimerEvent):void
{	
	Application.application.telaTransito.timerMensagemAguarde.stop();
	var veiculo:Veiculo = new Veiculo();
	var placasNoPatio:Array = Movimentacao.placasDeVeiculosNoPatio();
	var movAnterior:Movimentacao = new Movimentacao(true, null, 0, 0, false);
	var ok:Boolean = true;
	
	for each (var placa:String in placasNoPatio)
	{
		veiculo.obterDados(placa);
		movAnterior.obterDados(Movimentacao.getIdUltimaMovimentacao(placa).toString());
	
		var saida:Movimentacao = new Movimentacao(false, veiculo, 2, 1, movAnterior.getCobrancaNaEntrada());
		
		ok = ok && saida.registrarCorrecao(movAnterior.getT());
	}
	
	Application.application.mensagemAguarde.visible = false;
	
	if (ok)
	{
		mostrarCanvasMensagemGenerica	
		( "Todos os veículos saíram do pátio.",
			Utils.dataFormatada(saida.getT()).substr(11, 8), Utils.dataFormatada(saida.getT()).substr(0, 10)
		);
		
		tratarChangeEventData(new Event(Event.CHANGE));
		atualizarEstatisticas(false);
	}
}

public function confirmarMudancaIsento(placa:String):void
{
	checkboxVeiculoIsentoRegistrado.selected = !checkboxVeiculoIsentoRegistrado.selected;
	
	var veiculo:Veiculo = new Veiculo();
	veiculo.obterDados(placa);
	
	var mensagem:String = (veiculo.getIsento() == "1") 	? "Você deseja realmente tornar o veículo passível de cobranças futuras?"
														: "Você deseja realmente tornar o veículo isento de cobranças futuras?";
	
	Alert.show(mensagem, "Confirmar mudança de status de isento", Alert.YES|Alert.NO, null, mudarIsento);
	
	function mudarIsento(event:CloseEvent):void
	{
		if (event.detail == Alert.YES)
		{
			veiculo.setIsento((veiculo.getIsento() == "1") ? "0" : "1");
			veiculo.flush(veiculo.getPlaca());
			checkboxVeiculoIsentoRegistrado.selected = !checkboxVeiculoIsentoRegistrado.selected;
			toggleVeiculoIsentoRegistrado(new Event(Event.CHANGE));
		}
	}
}


