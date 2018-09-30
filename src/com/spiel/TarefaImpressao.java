package com.spiel;

import java.util.TimerTask;
import java.io.File;
import java.io.IOException;

public class TarefaImpressao extends TimerTask {
	
	private File arquivo;
	private long tempoUltimaModificacao;
	private Process processo;
	
	public TarefaImpressao(File arquivo) {
		this.arquivo = arquivo;
		this.tempoUltimaModificacao = arquivo.lastModified();
	}

	public void run() {
		if (		arquivo.exists()
				&&	tempoUltimaModificacao != arquivo.lastModified()
			)
		{
			try {
				System.out.println("    Imprimindo um comprovante...");
				processo = Runtime.getRuntime().exec("wordpad /p \"" + arquivo.getAbsolutePath() + "\"");
				tempoUltimaModificacao = arquivo.lastModified();
			} catch (IOException e) {
				System.out.println("Houve um problema: " + e.getMessage());
			}
		}
	}
}