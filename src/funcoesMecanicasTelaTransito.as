import mx.collections.ArrayCollection;
import mx.core.Application;
import mx.effects.Move;
import mx.effects.Resize;
import mx.events.EffectEvent;


public function isContraido():Boolean
{
	return !(Application.application.frameDireito.width == accordionAnotacoes.width);
}

public function redimensionaAccordionInferior(dimensionamento:String):void
{
	// Cria um efeito Resize, descobre se o accordion inferior visível no
	// momento é Anotações ou Ajuda ou nenhum e estabelece o redimensionamento
	// e posições finais com base no argumento "redimensionamento"
	
	var efeito:Resize = new Resize();
	var targets:ArrayCollection;
	
	/*if 	(	accordionAnotacoes.visible || 
			accordionAjuda.visible || 
			accordionVeiculoRegistrado.visible || 
			accordionRegistrarVeiculo.visible
		)
	{*/
		//Alert.show(accordionAnotacoes.visible.toString() + " " + accordionAjuda.visible.toString() + " " + accordionVeiculoRegistrado.visible.toString() + " " +accordionRegistrarVeiculo.visible.toString());
		
		targets = new ArrayCollection();    	
		//targets.addItem((accordionAnotacoes.visible) ? accordionAnotacoes : accordionAjuda);
		targets.addItem(accordionAnotacoes);
		targets.addItem(accordionAjuda);
		targets.addItem(accordionHistorico);
		targets.addItem(accordionSobreOSpiel);
		targets.addItem(accordionReimprimir);
		targets.addItem(boxFerramentas);
		efeito.targets = targets.toArray();
	//}
	
	//else
	
	//	return;
	
	//contraido = (dimensionamento == "contrair");	        	
	efeito.widthBy = (dimensionamento == "contrair") ? -250 : 250;	 
	efeito.addEventListener(EffectEvent.EFFECT_END, fInterna);
	efeito.play();
	
	function fInterna(event:EffectEvent):void
	{
		var targets:ArrayCollection = new ArrayCollection(efeito.targets);
		
		if (targets.contains(accordionAnotacoes))
		{
			if (dimensionamento == "contrair")
			{
				accordionAnotacoes.setStyle("center", 250);
			}
				
			else
			{
				accordionAnotacoes.setStyle("center", 0);
			}
		}
		
		else if (targets.contains(accordionAjuda))
		{
			if (dimensionamento == "contrair")
			{
				accordionAjuda.setStyle("center", 250);
				//contraido = true;
			}
				
			else
			{
				accordionAjuda.setStyle("center", 0);
				//contraido = false;
			}
		}
		
		else if (targets.contains(accordionHistorico))
		{
			if (dimensionamento == "contrair")
			{
				accordionHistorico.setStyle("center", 250);
				//contraido = true;
			}
				
			else
			{
				accordionHistorico.setStyle("center", 0);
				//contraido = false;
			}
		}
		
		else if (targets.contains(accordionSobreOSpiel))
		{
			if (dimensionamento == "contrair")
			{
				accordionSobreOSpiel.setStyle("center", 250);
				//contraido = true;
			}
				
			else
			{
				accordionSobreOSpiel.setStyle("center", 0);
				//contraido = false;
			}
		}
		
		else if (targets.contains(accordionReimprimir))
		{
			if (dimensionamento == "contrair")
			{
				accordionReimprimir.setStyle("center", 250);
				//contraido = true;
			}
				
			else
			{
				accordionReimprimir.setStyle("center", 0);
				//contraido = false;
			}
		}
		
		efeito.removeEventListener(EffectEvent.EFFECT_END, fInterna);
	}
}

public function redimensionaBoxFerramentas(dimensionamento:String):void
{
	var efeito:Resize = new Resize();
	efeito.target = boxFerramentas;
	
	efeito.widthBy = (dimensionamento == "contrair") ? -250 : 250;	 
	efeito.addEventListener(EffectEvent.EFFECT_END, fInterna);		
	//Alert.show(boxFerramentas.width.toString());
	efeito.play();
	//efeito.removeEventListener(EffectEvent.EFFECT_END);
	
	function fInterna(event:EffectEvent):void
	{
		//boxFerramentas.clearStyle("right");
		
		if (dimensionamento == "contrair")
		{
			boxFerramentas.setStyle("paddingRight", 250);
//			boxFerramentas.x -= 260;
		}
		
		else
		{
			boxFerramentas.clearStyle("paddingRight");
		}
		
	//	Alert.show(boxFerramentas.width.toString());
	}
}

public function moveBoxFerramentas(direcao:String):void
{
	// Move o HBox "boxFerramentas" e atribui posições finais
	// de acordo com o argumento "direcao"
	
	var efeito:Move = new Move();
	efeito.target = boxFerramentas;
	
	if (direcao == "acima" || direcao == "abaixo")
	{
		efeito.yBy = (direcao == "acima") ? -320 : 320;
	}
	
	efeito.addEventListener(EffectEvent.EFFECT_END, fInterna);
	efeito.duration = 1000;
	efeito.play();
	
	function fInterna():void
	{	
    	if (direcao == "acima" || direcao == "abaixo")
    	{
    		boxFerramentas.setStyle("bottom", (direcao == "acima") ? 330 : 10);
    	}
    	
    	botaoFecharBoxFerramentas.visible = (direcao == "acima");
	}
}

public function moveCanvasPlaca(direcao:String):void
{
	// Cria um efeito Move, atribui deslocamentos e posições finais
	// de acordo com o argumento "direcao" e o dispara
	
	var efeito:Move = new Move();	        	
	efeito.target = canvasPlaca;
	
	if (direcao == "esquerda" || direcao == "direita")
	{
		efeito.xBy = (direcao == "esquerda") ? -125 : 125;
		
		if (direcao == "esquerda" && !isContraido())
		{
			redimensionaAccordionInferior("contrair");
			redimensionaBoxFerramentas("contrair");
		}
			
		else if (isAccordionInferiorVisivel() && isContraido())
		{
			redimensionaAccordionInferior("expandir");
			redimensionaBoxFerramentas("expandir");
		}
		
		efeito.duration = 200;
	}
	
	else if (direcao == "acima" || direcao == "abaixo")
	{
		efeito.yBy = (direcao == "acima") ? -160 : 160;
	}
	
	efeito.addEventListener(EffectEvent.EFFECT_END, fInterna);
	efeito.play();
	
	function fInterna():void
	{
		if (direcao == "esquerda" || direcao == "direita")
    	{
    		canvasPlaca.setStyle("horizontalCenter", (direcao == "esquerda") ? -125 : 0);
    	}
    	
    	else if (direcao == "acima" || direcao == "abaixo")
    	{
    		canvasPlaca.setStyle("verticalCenter", (direcao == "acima") ? -160 : 0);
    	}
	}
}
