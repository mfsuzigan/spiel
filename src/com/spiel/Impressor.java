package com.spiel;

import java.util.*;
import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;

public class Impressor {

	private long intervalo;
	private File arquivo;
	private Timer timer;
	long tempoModificacao;
	
	public Impressor (long intervalo, File arquivo) {
		this.intervalo = intervalo;
		this.arquivo = arquivo;
		timer = new Timer(true);
		TarefaImpressao impressao = new TarefaImpressao(arquivo);
		timer.schedule(impressao, intervalo, intervalo);
		tempoModificacao = (arquivo.exists()) ? arquivo.lastModified() : -1;
	}
	
	public static void main(String[] args) {
		System.out.println("\n    Iniciando o monitoramento do diretorio de comprovantes...");
		long intervalo = Long.parseLong(args[1]);
		new Impressor(intervalo, new File(args[0]));
		try {		
			System.out.println("    Pronto.");
			Thread.sleep(Long.MAX_VALUE);
		} catch(Exception e) {
			System.out.println("Houve um problema: ");
		}
	}
}