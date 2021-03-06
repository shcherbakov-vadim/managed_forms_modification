&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ПараметрАвтотеста = "АвтоТест";	
КонецПроцедуры

&НаКлиенте
Процедура Проверить(Команда)
	Перем ИмяФормы;
	
	Если ЗначениеЗаполнено(ИмяПроверяемойФормы) Тогда
		ИменаФорм = Новый Массив;
		ИменаФорм.Добавить(ИмяПроверяемойФормы);
	Иначе
		ИменаФорм = ПолучитьИменаФормДляПроверки();
	КонецЕсли;

	Для Каждого ИмяФормы Из ИменаФорм Цикл
		ЗначенияЗаполнения = Новый Структура("МОД_МодификацияУправляемыхФорм_Параметры");
		
		Если ЗначениеЗаполнено(ПараметрАвтотеста) Тогда
			ИнформацияОбОшибке = Неопределено;
			Попытка
				ПараметрыФормы = Новый Структура(ПараметрАвтотеста, Истина);
				Форма = ПолучитьФорму(ИмяФормы, ПараметрыФормы);
			Исключение
				ИнформацияОбОшибке = ИнформацияОбОшибке();	
			КонецПопытки;
			
			Если Форма <> Неопределено Тогда
				ЗаполнитьЗначенияСвойств(ЗначенияЗаполнения, Форма);
			КонецЕсли;
			
			Если ИнформацияОбОшибке <> Неопределено
				И (ИнформацияОбОшибке.ИмяМодуля = "ОбщийМодуль.МОД_МодификацияУправляемыхФорм.Модуль"
					ИЛИ ЗначенияЗаполнения.МОД_МодификацияУправляемыхФорм_Параметры = Неопределено) Тогда
				
				Сообщить(СтрШаблон("ПолучитьФорму: %1; %2; %3", ИмяФормы, ИнформацияОбОшибке.ИмяМодуля, ИнформацияОбОшибке.Описание), СтатусСообщения.Важное);
				Продолжить;
			КонецЕсли;
		КонецЕсли;
			
		Если ЗначенияЗаполнения.МОД_МодификацияУправляемыхФорм_Параметры = Неопределено Тогда
			ИнформацияОбОшибке = Неопределено;
			Попытка
				Форма = ПолучитьФорму(ИмяФормы);
			Исключение
				ИнформацияОбОшибке = ИнформацияОбОшибке();	
			КонецПопытки;
			
			Если Форма <> Неопределено Тогда
				ЗаполнитьЗначенияСвойств(ЗначенияЗаполнения, Форма);
			КонецЕсли;
			
			Если ИнформацияОбОшибке <> Неопределено
				И (ИнформацияОбОшибке.ИмяМодуля = "ОбщийМодуль.МОД_МодификацияУправляемыхФорм.Модуль"
					ИЛИ ЗначенияЗаполнения.МОД_МодификацияУправляемыхФорм_Параметры = Неопределено) Тогда
				
				Сообщить(СтрШаблон("ПолучитьФорму: %1; %2; %3", ИмяФормы, ИнформацияОбОшибке.ИмяМодуля, ИнформацияОбОшибке.Описание), СтатусСообщения.Важное);
				Продолжить;
			КонецЕсли;
			
		КонецЕсли;
		
		Если ЗначенияЗаполнения.МОД_МодификацияУправляемыхФорм_Параметры = Неопределено Тогда
			Сообщить(СтрШаблон("Изменения формы %1 не были применены", ИмяФормы), СтатусСообщения.Важное);
		КонецЕсли;
	КонецЦикла;
	
	Сообщить(СтрШаблон("Проверено %1 форм", ИменаФорм.Количество()));
КонецПроцедуры

&НаСервере
Функция ПолучитьИменаФормДляПроверки()
	ИменаФорм = Новый Массив;;
	
	ИменаКоллекций = Новый Массив;
	ИменаКоллекций.Добавить("БизнесПроцессы");
	ИменаКоллекций.Добавить("Документы");
	ИменаКоллекций.Добавить("ЖурналыДокументов");
	ИменаКоллекций.Добавить("Задачи");
	//ИменаКоллекций.Добавить("КритерииОтбора");
	ИменаКоллекций.Добавить("Обработки");
	ИменаКоллекций.Добавить("Отчеты");
	ИменаКоллекций.Добавить("Перечисления");
	ИменаКоллекций.Добавить("ПланыВидовРасчета");
	ИменаКоллекций.Добавить("ПланыВидовХарактеристик");
	ИменаКоллекций.Добавить("ПланыОбмена");
	ИменаКоллекций.Добавить("ПланыСчетов");
	ИменаКоллекций.Добавить("РегистрыБухгалтерии");
	ИменаКоллекций.Добавить("РегистрыНакопления");
	ИменаКоллекций.Добавить("РегистрыРасчета");
	ИменаКоллекций.Добавить("РегистрыСведений");
	ИменаКоллекций.Добавить("Справочники");
	ИменаКоллекций.Добавить("ХранилищаНастроек");
	
	Для Каждого ИмяКоллекции Из ИменаКоллекций Цикл
		Для Каждого ОбъектМетаданных Из Метаданные[ИмяКоллекции] Цикл
			Для Каждого МетаданныеФормы Из ОбъектМетаданных.Формы Цикл
				ИмяМакетаИзменений = "МОД_Модификация_" + МетаданныеФормы.Имя;
				Если ОбъектМетаданных.Макеты.Найти(ИмяМакетаИзменений) <> Неопределено Тогда
					ИменаФорм.Добавить(МетаданныеФормы.ПолноеИмя());
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Для Каждого МетаданныеФормы Из Метаданные.ОбщиеФормы Цикл
		ИмяМакетаИзменений = "МОД_Модификация_" + МетаданныеФормы.Имя;
		Если Метаданные.ОбщиеМакеты.Найти(ИмяМакетаИзменений) <> Неопределено Тогда
			ИменаФорм.Добавить(МетаданныеФормы.ПолноеИмя());
		КонецЕсли;
	КонецЦикла;
	
	Возврат ИменаФорм;
КонецФункции
