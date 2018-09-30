// ActionScript file
import com.spiel.Conexao;
import com.spiel.ConexaoComBD;
import com.spiel.Configuracoes;
import com.spiel.Marca;
import com.spiel.Modelo;
import com.spiel.Movimentacao;
import com.spiel.Utils;
import com.spiel.Veiculo;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.net.FileFilter;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.RadioButton;
import mx.core.Application;
import mx.events.CloseEvent;

public function initConfiguracoes():void
{
	inputEditarModelo.text = "";
	inputNovoModelo.text = "";
	
	radioNovoModelo.selected = true;
	
	inputNovoModelo.enabled = true;
	comboboxNovoModeloMarcas.enabled = true;
	
	comboboxEditarModelo.enabled = false;
	inputEditarModelo.enabled = false;
	comboboxEditarModeloMarcas.enabled = false;
	
	var marcas:Array = Marca.getNomesMarcas();
	marcas.sort(Array.CASEINSENSITIVE);
	
	comboboxNovoModeloMarcas.dataProvider = marcas;
	comboboxNovoModeloMarcas.selectedIndex = -1;
	
	comboboxEditarModeloMarcas.dataProvider = marcas;
	comboboxEditarModeloMarcas.selectedIndex = -1;
	
	comboboxEditarModelo.dataProvider = Modelo.getNomesModelos().sort(Array.CASEINSENSITIVE);
	
	
	if (accordionConfiguracoes.selectedIndex == 4 && inputTarifa is Object)	
		inputTarifa.text = Utils.formatarDinheiro(Configuracoes.getTarifa());
	
}
/*
public function apagarMovimentacoesPorMes(item:Object):void
{
	Alert.show("Isso apagará todas as movimentações deste mês. Deseja prosseguir?", "Apagar movimentações do mês", Alert.YES|Alert.NO, null, interna);
	
	function interna(event:CloseEvent):void
	{
		if (event.detail == Alert.NO)
			return;
			
		Alert.show(item.mes);
			
		tabelaMovimentacoesPorMes.selectedIndex = -1;
		botaoApagarMovimentacoes.enabled = false;
	}
}

public function povoarTabelaMovimentacoesPorMes():void
{
	botaoApagarMovimentacoes.enabled = false;
	tabelaMovimentacoesPorMes.dataProvider = Movimentacao.nroMovimentacoesPorMes();
}
*/

public function tratarSelecaoModelo():void
{
	
	var modelo:Modelo = new Modelo(true, null, null);
	modelo.obterDados(comboboxEditarModelo.text);
		
	var marca:Marca = new Marca(true, null);
	marca.obterDadosPorId(modelo.getIdMarca());
	
	inputEditarModelo.text = comboboxEditarModelo.text;
	comboboxEditarModeloMarcas.text = marca.getNome();
	
	if (comboboxEditarModelo.text != "")
	{
		inputEditarModelo.enabled = true;
		comboboxEditarModeloMarcas.enabled = true;
	}
}

public function atualizarTarifa():void
{
	inputTarifa.text = Utils.formatarDinheiro(Configuracoes.getTarifa());
}

public function validarTarifa():void
{
	if (Utils.validarInputNumerico(inputTarifa) == false)
		return;
		
	Application.application.mostrarPainelSenha('tarifa');
}

public function salvarModelo():void
{
	var sucesso:Boolean = false;
	var marca:Marca = new Marca(true, null);
	var modelosMarca:ArrayCollection;
	
	if (radioNovoModelo.selected)
	{
		marca.obterDados(comboboxNovoModeloMarcas.text);
		modelosMarca = new ArrayCollection(Modelo.getNomesModelosDeMarca(marca.getId()));
		
		if (modelosMarca.contains(inputNovoModelo.text))
		{
			Alert.show("Já existe modelo de tal nome para a marca escolhida.", "Erro");
			return;
		}
		
		else if (inputNovoModelo.text == "")
		{
			Alert.show("Um nome de modelo deve ser informado.", "Erro");
			return;
		}
		
		var novoModelo:Modelo = new Modelo(false, inputNovoModelo.text, marca.getId());
		sucesso = novoModelo.registrar()
		
		if (sucesso)
		{
			Alert.show("Modelo salvo com sucesso.", "Modelo salvo");
		}
	}
	
	else
	{
		marca.obterDados(comboboxEditarModeloMarcas.text);
		modelosMarca = new ArrayCollection(Modelo.getNomesModelosDeMarca(marca.getId()));
		
		if (modelosMarca.contains(inputEditarModelo.text))
		{
			Alert.show("Já existe modelo de tal nome para a marca escolhida.", "Erro");
			return;
		}
		
		else if (inputEditarModelo.text == "")
		{
			Alert.show("Um nome de modelo deve ser informado.", "Erro");
			return;
		}
		
		var modelo:Modelo = new Modelo(true, null, null);
		modelo.obterDados(comboboxEditarModelo.text);
		
		var marcaEscolhida:Marca = new Marca(true, null);
		marcaEscolhida.obterDados(comboboxEditarModeloMarcas.text);
		
		modelo.setIdMarca(marcaEscolhida.getId());
		modelo.setNome(inputEditarModelo.text);
		sucesso = modelo.flush();
		
		if (sucesso)
		{
			inputEditarModelo.enabled = false;
			comboboxEditarModeloMarcas.enabled = false;			
			
			Alert.show("Modelo atualizado com sucesso.", "Modelo atualizado");
		}
	}
	
	if (sucesso)
	{
		comboboxEditarModelo.selectedIndex = -1;		
		comboboxEditarModeloMarcas.text = "";
		
		inputEditarModelo.text = "";		
		inputNovoModelo.text = "";
		
		comboboxNovoModeloMarcas.selectedIndex = -1;
		
		comboboxEditarModelo.dataProvider = Modelo.getNomesModelos().sort(Array.CASEINSENSITIVE);
	}
}

public function salvarMarca():void
{
	var marcas:ArrayCollection = new ArrayCollection(Marca.getNomesMarcas());
	
	if (marcas.contains(inputMarca.text))
	{
		Alert.show("Já existe marca de tal nome.", "Erro");
		return;
	}
	
	var marca:Marca = new Marca(false, inputMarca.text);
	
	if (marca.registrar())
	{
		Alert.show("Marca salva com sucesso.", "Marca salva");
	}
}

public function gerarBackupDoBD():void
{		
	var pathAlvo:File = File.documentsDirectory;
	pathAlvo.addEventListener(Event.SELECT, fInterna);
	
	try
	{
		pathAlvo.browseForSave("Salvar cópia do banco de dados como...");
	} 
	
	catch (erro:Error) {
		Alert.show("Falha ao selecionar caminho para cópia do banco de dados: " 
		+ erro.message, "Erro");
	}
	
	function fInterna(event:Event):void
	{
		var dirApp:String = File.applicationDirectory.nativePath;
		dirApp.replace("\\", "\\\\");
		
		var pathBD:String = 
			dirApp 
			+ "\\resources\\database\\spiel.db";
			
			
		var alvo:File = event.target as File;
		
		if (alvo.extension != "db")
			alvo.nativePath += ".db";	
										
		var bancoDeDados:File = new File(pathBD);	
		bancoDeDados.copyTo(alvo, true);
		
		Alert.show("Cópia do banco de dados salva com sucesso.", "Cópia salva");
	}	
}

public function confirmarAgregarDadosDeBD():void
{	
	Alert.show("Isso irá alterar permanentemente o banco de dados. Deseja prosseguir?", 
		"Agregar informações ao banco de dados",
		Alert.YES|Alert.NO,
		null,
		fInterna);
	
	function fInterna(event:CloseEvent):void
	{
		if (event.detail == Alert.NO)
			return;
		
		var pathAlvo:File = File.documentsDirectory;
		pathAlvo.addEventListener(Event.SELECT, fInterna2);
		
		try
		{
			pathAlvo.browseForOpen("Selecionar backup do banco de dados...", [new FileFilter("Data Base File (*.db)", "*.db")]);
		} 
		
		catch (erro:Error) {
			Alert.show("Falha ao selecionar backup do banco de dados: " 
			+ erro.message, "Erro");
		}
		
		function fInterna2(event:Event):void
		{
			Application.application.mensagemAguarde.visible = true;
			
			var timer:Timer = new Timer(100, 0);
			timer.addEventListener(TimerEvent.TIMER, f);
			timer.start();
			var arquivo:File = event.target as File;
			
			function f(event:TimerEvent):void
			{
				timer.stop();
				agregarDadosDeBD(arquivo);
			}			
		}
	}	
}

public function agregarDadosDeBD(arquivo:File):void
{	
	var r:SQLResult;	
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new ConexaoComBD(arquivo);	
	stmt.addEventListener(SQLEvent.RESULT, tratadora);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
	
	//Alert.show(stmt.sqlConnection.connected.toString());
	
	var placasRegistradas:ArrayCollection = new ArrayCollection(Veiculo.placasRegistradas());
	var movimentacoesRegistradas:ArrayCollection = new ArrayCollection(Movimentacao.getTimestamps());
	var filtroMovimentacoes:String = "(";
	
	for (var j:Number = 0; j < movimentacoesRegistradas.length; j++)
	{
		filtroMovimentacoes += movimentacoesRegistradas.getItemAt(j).toString();
		filtroMovimentacoes += (j == movimentacoesRegistradas.length - 1) ? ")" : ", ";
	}
	
	var comandoObterDados:String =	
		"select CREDITO, VEICULOS.PLACA, ID_MODELO, ID_COR, ISENTO, VEICULO_ISENTO, T, CODIGO, CODIGO0, TARIFA, CRED_DEDUZIDO " +
		"from MOVIMENTACOES, VEICULOS " +
		"where VEICULOS.PLACA = MOVIMENTACOES.PLACA " + 
		"and T not in " + filtroMovimentacoes + ";";
	
	stmt.text = comandoObterDados;	
	stmt.execute();
	
	function tratadora(event:SQLEvent):void
	{
		r = stmt.getResult();
		var nroVeiculosInseridos:Number = 0;
		var nroMovimentacoesInseridas:Number = 0;
		
		if (r is Object && r.data is Object)
		{
			
			for (var i:Number = 0; i < r.data.length; i++)
			{	
				var tPesquisado:String = r.data[i].T.toString();
					
				if (!placasRegistradas.contains(r.data[i].PLACA.toString()))
				{	
					
					var veiculo:Veiculo = new Veiculo();			
					veiculo.setPlaca(r.data[i].PLACA.toString());
					veiculo.setIdModelo(r.data[i].ID_MODELO.toString());
					veiculo.setIdCor(r.data[i].ID_COR.toString());
					veiculo.setIsento(r.data[i].ISENTO.toString());
					veiculo.setCredito(r.data[i].CREDITO.toString());

					veiculo.inserir();
					placasRegistradas.addItem(r.data[i].PLACA.toString());
					nroVeiculosInseridos++;
				}
				
				var movimentacao:Movimentacao = new Movimentacao(true, null, 0, 0, false);
				movimentacao.obterDadosPorTimestampComConexao(tPesquisado, new ConexaoComBD(arquivo));
				movimentacao.registrarComT(tPesquisado);
				nroMovimentacoesInseridas++;	
			}
		}
		
		Application.application.mensagemAguarde.visible = false;
		Application.application.atualizarEstatisticas();
		Alert.show("Foram inseridos " + nroVeiculosInseridos + " veículos e " + nroMovimentacoesInseridas + " movimentações.", "Informações agregadas");
	}
	
	function tratadoraErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao agregar requisições de arquivo: " + event.error.details);
	}
}

public function toggleRadiosModelos(event:MouseEvent):void
{
	var radio:RadioButton = (event.target as RadioButton);			
			
	if (radio.id == "radioNovoModelo")
	{
		comboboxEditarModelo.enabled = false;
		comboboxEditarModelo.selectedIndex = -1;
		
		inputEditarModelo.enabled = false;
		inputEditarModelo.text = "";
		
		comboboxEditarModeloMarcas.enabled = false;
		comboboxEditarModeloMarcas.selectedIndex = -1;
		
		inputNovoModelo.enabled = true;
		comboboxNovoModeloMarcas.enabled = true;
	}
	
	else if (radio.id == "radioEditarModelo")
	{
		inputNovoModelo.enabled = false;
		inputNovoModelo.text = "";
		
		comboboxNovoModeloMarcas.enabled = false;
		comboboxNovoModeloMarcas.selectedIndex = -1;
		
		comboboxEditarModelo.enabled = true;
	}	
}

public function confirmarLimparHistorico():void
{	
	Alert.show("Isso excluirá todas as movimentações de entrada e saída do pátio (um arquivo de backup será gerado automaticamente). Deseja prosseguir?", 
		"Limpar histórico",
		Alert.YES|Alert.NO,
		null,
		fInterna);
	
	function fInterna(event:CloseEvent):void
	{
		if (event.detail == Alert.NO)
			return;
		
		Application.application.mensagemAguarde.visible = true;
			
		var timer:Timer = new Timer(100, 0);
		timer.addEventListener(TimerEvent.TIMER, f);
		timer.start();
		
		function f(event:TimerEvent):void
		{
			timer.stop();
			limparHistorico();
		}			
	}	
}

public function limparHistorico():void
{		
	var stmt:SQLStatement = new SQLStatement();
	stmt.sqlConnection = new Conexao();	
	stmt.addEventListener(SQLEvent.RESULT, tratadora);
	stmt.addEventListener(SQLErrorEvent.ERROR, tratadoraErro);
	
	var dirApp:String = File.applicationDirectory.nativePath;
	dirApp.replace("\\", "\\\\");
	
	var pathBD:String = 
		dirApp 
		+ "\\resources\\database\\spiel.db";
	
	var pathBackup:String = 
		dirApp 
		+ "\\resources\\database\\backup_pre_limparHistorico_" + Utils.getStringInstante(new Date()) + ".db";
									
	var bancoDeDados:File = new File(pathBD);
	var backup:File = new File(pathBackup);
	bancoDeDados.copyTo(backup, true);
	
	var nroMovimentacoesApagadas:Number = Movimentacao.nroMovimentacoesDeletaveis();
	
	var comandoObterDados:String =	
		"delete " +
		"from MOVIMENTACOES " +
		"where codigo <> 0;";
	
	stmt.text = comandoObterDados;	
	stmt.execute();
	
	function tratadora(event:SQLEvent):void
	{
		Application.application.mensagemAguarde.visible = false;
		Application.application.atualizarEstatisticas();
		
		var mensagem:String = (nroMovimentacoesApagadas == 1) ? "Foi excluída " : "Foram excluídas ";
		mensagem += nroMovimentacoesApagadas.toString();
		mensagem += (nroMovimentacoesApagadas == 1) ? " movimentação" : " movimentações.";
		mensagem += "\n\nO seguinte arquivo de backup foi gerado:\n\n" + backup.nativePath;
		
		Alert.show(mensagem, "Histórico limpo");
	}
	
	function tratadoraErro(event:SQLErrorEvent):void
	{
		Alert.show("Erro ao limpar histórico: " + event.error.details);
	}
}
