package com.spiel
{
	import mx.collections.ArrayCollection;
	import mx.events.ValidationResultEvent;
	import mx.validators.RegExpValidator;
	import mx.validators.Validator;
	
	public class Utils
	{
		public function Utils()
		{
		}
		
		public static function adicionarOpcaoTodos(array:Array, generoMasculino:Boolean):Array
		{
			var ac:ArrayCollection = new ArrayCollection(array);
			ac.addItemAt((generoMasculino ? "Todos" : "Todas"), 0);
			
			return ac.toArray();
		}
		
		public static function adicionarOpcaoTodosEspecifica(array:Array, elemento:String):Array
		{
			var ac:ArrayCollection = new ArrayCollection(array);
			var stringElemento:String = "";
			
			switch(elemento)
			{
				case "modelo":
					stringElemento = "Todos os modelos";
					break;
				
				case "marca":
					stringElemento = "Todas as marcas";
					break;
					
				case "cor":
					stringElemento = "Todas as cores";
					break;
			}
			
			ac.addItemAt(stringElemento, 0);
			return ac.toArray();
		}
		
		public static function getStringInstante(d:Date):String
		{
			//var agora:Date = new Date();
			var ano:String = d.fullYear.toString();
			var mes:String = String(((d.month + 1) > 0 && (d.month + 1) < 10) ? "0" + (d.month + 1) : (d.month + 1));
			var dia:String = String((d.date > 0 && d.date < 10) ? "0" + d.date : d.date);
			var horas:String = String((d.hours >= 0 && d.hours < 10) ? "0" + d.hours : d.hours);
			var minutos:String = String((d.minutes >= 0 && d.minutes < 10) ? "0" + d.minutes : d.minutes);
			var segundos:String = String((d.seconds >= 0 && d.seconds < 10) ? "0" + d.seconds : d.seconds);
			
			var milissegundos:String;
			
			if (d.milliseconds >= 0 && d.milliseconds < 10)
			{
				milissegundos = "00" + d.milliseconds;
			}
			
			else if (d.milliseconds >= 10 && d.milliseconds < 100)
			{
				milissegundos = "0" + d.milliseconds;
			}
			
			else
			{
				milissegundos = d.milliseconds.toString();
			}
			
			return ano + mes + dia + horas + minutos + segundos + milissegundos;
		}
		
		public static function getStringInstanteFinalDoDia(timestamp:String):String
		{	
			return timestamp.substr(0, 8) + "23" + "59" + "59" + "999";
		}
		
		public static function getStringInstantePreencherCom9s(d:Date):String
		{
			//var agora:Date = new Date();
			var ano:String = d.fullYear.toString();
			var mes:String = String(((d.month + 1) > 0 && (d.month + 1) < 10) ? "0" + (d.month + 1) : (d.month + 1));
			var dia:String = String((d.date > 0 && d.date < 10) ? "0" + d.date : d.date);
			//var horas:String = String((d.hours >= 0 && d.hours < 10) ? "0" + d.hours : d.hours);
			//var minutos:String = String((d.minutes >= 0 && d.minutes < 10) ? "0" + d.minutes : d.minutes);
			//var segundos:String = String((d.seconds >= 0 && d.seconds < 10) ? "0" + d.seconds : d.seconds);
			
			//var milissegundos:String;
			/*
			if (d.milliseconds >= 0 && d.milliseconds < 10)
			{
				milissegundos = "00" + d.milliseconds;
			}
			
			else if (d.milliseconds >= 10 && d.milliseconds < 100)
			{
				milissegundos = "0" + d.milliseconds;
			}
			
			else
			{
				milissegundos = d.milliseconds.toString();
			}
			*/
			return ano + mes + dia + "99" + "99" + "99" + "999";
		}
		
		public static function getStringDia(d:Date):String
		{
			var ano:String = d.fullYear.toString();
			var mes:String = String(((d.month + 1) > 0 && (d.month + 1) < 10) ? "0" + (d.month + 1) : (d.month + 1));
			var dia:String = String((d.date > 0 && d.date < 10) ? "0" + d.date : d.date);
			
			return ano + mes + dia + "00" + "00" + "00" + "000";
		}
		
		public static function getStringDiaSemHorario(d:Date):String
		{
			var ano:String = d.fullYear.toString();
			var mes:String = String(((d.month + 1) > 0 && (d.month + 1) < 10) ? "0" + (d.month + 1) : (d.month + 1));
			var dia:String = String((d.date > 0 && d.date < 10) ? "0" + d.date : d.date);
			
			return ano + mes + dia;
		}
		
		public static function getStringHojeComHorario(h:String, m:String):String
		{
			var d:Date = new Date();
			var ano:String = d.fullYear.toString();
			var mes:String = String(((d.month + 1) > 0 && (d.month + 1) < 10) ? "0" + (d.month + 1) : (d.month + 1));
			var dia:String = String((d.date > 0 && d.date < 10) ? "0" + d.date : d.date);
			
			var output:String = ano + mes + dia;
			output += (Number(h) < 10) ? ("0" + h) : h;
			output += (Number(m) < 10) ? ("0" + m) : m;
			
			return output + "000";
		}
		
		public static function getStringDiaComHorario(d:Date, h:String, m:String):String
		{
			var ano:String = d.fullYear.toString();
			var mes:String = String(((d.month + 1) > 0 && (d.month + 1) < 10) ? "0" + (d.month + 1) : (d.month + 1));
			var dia:String = String((d.date > 0 && d.date < 10) ? "0" + d.date : d.date);
			
			var output:String = ano + mes + dia;
			output += (Number(h) < 10) ? ("0" + h) : h;
			output += (Number(m) < 10) ? ("0" + m) : m;
			
			return output + "000";
		}
		
		public static function getStringHojeSemHorario():String
		{
			return getStringDiaSemHorario(new Date());
		}
		
		public static function getStringAgora(incluirMilissegundos:Boolean):String
		{
			var d:Date = new Date();
			
			if (!incluirMilissegundos)
			{
				d.setMilliseconds(0);
			}
			
			return Utils.getStringInstante(d);
		}
	
		public static function isInteiro(string:String):Boolean
		{
			return (RegExp)(/^\d+$/).test(string);
		}
		
		public static function isMonetario(string:String):Boolean
		{
			return (RegExp)(/^\d+,\d\d$/).test(string);
		}
	
		public static function dataFormatada(timestamp:String):String
		{
			var dataFormatada:String = timestamp.substr(6, 2);
			dataFormatada += "/";
			dataFormatada += timestamp.substr(4, 2);
			dataFormatada += "/";
			dataFormatada += timestamp.substr(0, 4);
			
			dataFormatada += " ";
			
			dataFormatada += timestamp.substr(8, 2);
			dataFormatada += ":";
			dataFormatada += timestamp.substr(10, 2);
			dataFormatada += ":";
			dataFormatada += timestamp.substr(12, 2);
			
			return dataFormatada;	
		}
		
		public static function dataFormatadaSemHorario(timestamp:String):String
		{
			var dataFormatada:String = timestamp.substr(6, 2);
			dataFormatada += "/";
			dataFormatada += timestamp.substr(4, 2);
			dataFormatada += "/";
			dataFormatada += timestamp.substr(0, 4);
						
			return dataFormatada;	
		}
		
		public static function dataFormatadaHifen(timestamp:String):String
		{
			var dataFormatada:String = timestamp.substr(6, 2);
			dataFormatada += "-";
			dataFormatada += timestamp.substr(4, 2);
			dataFormatada += "-";
			dataFormatada += timestamp.substr(0, 4);
			
			dataFormatada += " ";
			
			dataFormatada += timestamp.substr(8, 2);
			dataFormatada += "h";
			dataFormatada += timestamp.substr(10, 2);
			dataFormatada += "min";
			dataFormatada += timestamp.substr(12, 2);
			
			return dataFormatada;	
		}
	
		public static function getStringInstanteDH(d:String, h:String):String
		{
			// Entradas: d = 28/01/2011, h = 16:59:59
			// Saída: timestamp = 20110128165959000
			
			var timestamp:String = d.substr(6, 4);
			timestamp += d.substr(3, 2);
			timestamp += d.substr(0, 2);
			
			timestamp += h.substr(0, 2)
			timestamp += h.substr(3, 2);
			timestamp += h.substr(6, 2);
			timestamp += "000";
			
			return timestamp;
		}
		
		public static function getStringInstanteDH2(dH:String):String
		{
			// Entrada: dH = 28/01/2011 16:59:59
			// Saída: timestamp = 20110128165959000
			
			var timestamp:String = dH.substr(6, 4);
			timestamp += dH.substr(3, 2);
			timestamp += dH.substr(0, 2);
			
			timestamp += dH.substr(11, 2)
			timestamp += dH.substr(14, 2);
			timestamp += dH.substr(17, 2);
			timestamp += "000";
			
			return timestamp;
		}
		
		public static function stringIsBlank(str:String):Boolean{
			return str == null || str == "";
		}
	
		public static function validarObrigatoriedadeInput(alvo:Object):Boolean
		{
			var validador:Validator = new Validator();
			validador.required = true;
			validador.requiredFieldError = "Obrigatório";
			validador.source = alvo;
			validador.property = "text";
						
			var resultEvent:ValidationResultEvent = validador.validate();
			return (resultEvent.type == ValidationResultEvent.VALID);
		}
	
		public static function validarInput(alvo:Object):Boolean
		{
			var validador:RegExpValidator = new RegExpValidator();
			validador.required = false;
			validador.noMatchError = "Um ou mais caracteres inválidos encontrados: ', \x22, *, \x26 ou $";
			validador.expression="^[^'\x22\*\x26\$]*$";
			validador.source = alvo;
			validador.property = "text";
						
			var resultEvent:ValidationResultEvent = validador.validate();
			return (resultEvent.type == ValidationResultEvent.VALID);
		}
		
		public static function validarInputNumerico(alvo:Object):Boolean
		{
			var validador:RegExpValidator = new RegExpValidator();
			validador.required = false;
			validador.noMatchError = "Um ou mais caracteres inválidos encontrados.";
			validador.expression="^([0-9]+,[0-9]|[0-9]+)+$";
			validador.source = alvo;
			validador.property = "text";
						
			var resultEvent:ValidationResultEvent = validador.validate();
			return (resultEvent.type == ValidationResultEvent.VALID);
		}
		
		public static function formatarDinheiro(quantia:String):String
		{
			var quantiaFormatada:String;
			
			if (Number(quantia) % 1 == 0)
			{
				quantiaFormatada = quantia + ",00";
			}
				
			else
			{
				quantiaFormatada = Number(quantia).toFixed(2).replace(".", ",");
			}
			
			return quantiaFormatada;	
		}
		
		public static function obterValorNumerico(str:String):Number {
			
			var valorNumerico:String = "0";
			
			if (!stringIsBlank(str)){
				valorNumerico = str.replace(",", ".");
			}
			
			return Number(valorNumerico);
		}
	
		public static function getDate(timestamp:String):Date
		{
			var d:Date = new Date();
			d.setFullYear(Number(timestamp.substr(0, 4)));
			d.setMonth(Number(timestamp.substr(4, 2)) - 1);
			d.setDate(Number(timestamp.substr(6, 2)));
			d.setHours(Number(timestamp.substr(8, 2)));
			d.setMinutes(Number(timestamp.substr(10, 2)));
			d.setSeconds(Number(timestamp.substr(12, 2)));
			
			return d;
		}
		
		public static function somarHorarios(strTimestamp:String, strHoras:String, strMinutos:String):String
		{
			var dateTimestamp:Date = Utils.getDate(strTimestamp);
			dateTimestamp.setHours(dateTimestamp.hours + Number(strHoras));
			dateTimestamp.setMinutes(dateTimestamp.minutes + Number(strMinutos));
			
			return Utils.getStringInstante(dateTimestamp);
		}
		
		public static function subtrairHorarios(strTimestamp:String, strHoras:String, strMinutos:String):String
		{
			var dateTimestamp:Date = Utils.getDate(strTimestamp);
			dateTimestamp.setHours(dateTimestamp.hours - Number(strHoras));
			dateTimestamp.setMinutes(dateTimestamp.minutes - Number(strMinutos));
			
			return Utils.getStringInstante(dateTimestamp);
		}
	}
}