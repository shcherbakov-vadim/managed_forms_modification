&НаКлиенте
Процедура ВыполнитьКонвертацию(Команда)
	РабочийКаталог = ПолучитьИмяВременногоФайла();
	ОписанияМакетов = ПолучитьОписанияМакетовИзменений(РабочийКаталог);
	
	ПараметрыОбработчика = Новый Структура("РабочийКаталог,ОписанияМакетов", РабочийКаталог, ОписанияМакетов);
	ОбработчикПродолжения = Новый ОписаниеОповещения("ВыполнитьКонвертациюПослеСозданияКаталога", ЭтаФорма, ПараметрыОбработчика);
	НачатьСозданиеКаталога(ОбработчикПродолжения, РабочийКаталог);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьКонвертациюПослеСозданияКаталога(ИмяКаталога, ДополнительныеПараметры) Экспорт
	ОбработчикПродолжения = Новый ОписаниеОповещения("ВыполнитьКонвертациюПослеВыгрузкиМакетов", ЭтаФорма, ДополнительныеПараметры);
	ВыгрузитьМакеты(ДополнительныеПараметры, ОбработчикПродолжения);
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьКонвертациюПослеВыгрузкиМакетов(Результат, ДополнительныеПараметры) Экспорт
	ОбновитьСостояниеВыполнения(НСтр("ru = 'Обработка макетов'"));
	
	ФайлыДляЗагрузки = Новый Массив;
	
	Для Каждого ОписаниеМакета Из ДополнительныеПараметры.ОписанияМакетов Цикл
		Если СтрЗаканчиваетсяНа(ОписаниеМакета.ПутьКМакету, "xml") Тогда
			ТекстМакета = ПолучитьJSONМакета(ОписаниеМакета.ПолноеИмя);
			// учет особенности записи строки в файл
			ТекстМакета = СтрЗаменить(ТекстМакета, Символы.ВК + Символы.ПС, Символы.ПС);
			
			МассивПуть = СтрРазделить(ОписаниеМакета.ПутьКМакету, ПолучитьРазделительПути());
			МассивИмя = СтрРазделить(МассивПуть[МассивПуть.ВГраница()], ".");
			МассивИмя[МассивИмя.ВГраница()] = "txt";
			МассивПуть[МассивПуть.ВГраница()] = СтрСоединить(МассивИмя, ".");
			
			НовоеИмя = СтрСоединить(МассивПуть, ПолучитьРазделительПути());
			
			ЗаписьТекста = Новый ЗаписьТекста;
			ЗаписьТекста.Открыть(НовоеИмя, "UTF-8");
			ЗаписьТекста.Записать(ТекстМакета);
			ЗаписьТекста.Закрыть();
			
			ТекстовыйДокумент = Новый ТекстовыйДокумент;
			ТекстовыйДокумент.Прочитать(ОписаниеМакета.ПутьКОбъекту);
			
			ТекстовыйДокумент.УстановитьТекст(СтрЗаменить(ТекстовыйДокумент.ПолучитьТекст()
				,"<TemplateType>SpreadsheetDocument</TemplateType>"
				,"<TemplateType>TextDocument</TemplateType>"));
			ТекстовыйДокумент.Записать(ОписаниеМакета.ПутьКОбъекту);
			
			ФайлыДляЗагрузки.Добавить(ОписаниеМакета.ПутьКОбъекту);
		КонецЕсли;
	КонецЦикла;
	
	ПутьКСпискуФайлов = ДобавитьРазделительПути(ДополнительныеПараметры.РабочийКаталог) + "import.txt";
	
	ЗаписьТекста = Новый ЗаписьТекста(ПутьКСпискуФайлов, "UTF-8");
	ЗаписьТекста.Записать(СтрСоединить(ФайлыДляЗагрузки, Символы.ПС));
	ЗаписьТекста.Закрыть();
	
	ЗагрузитьМакеты(ДополнительныеПараметры, ПутьКСпискуФайлов);
КонецПроцедуры

&НаСервере
Функция ПолучитьJSONМакета(ИмяМакета)
	МетаданныеМакета = Метаданные.НайтиПоПолномуИмени(ИмяМакета);
	Если Метаданные.ОбщиеМакеты.Содержит(МетаданныеМакета) Тогда
		ДанныеМакета = ПолучитьОбщийМакет(МетаданныеМакета.Имя);
	Иначе
		МенеджерОбъектов = МенеджерПоПолномуИмени(ИмяМакета);
		ДанныеМакета = МенеджерОбъектов.ПолучитьМакет(МетаданныеМакета.Имя);
	КонецЕсли;
	
	ОбработкаКонвертации = Обработки.МОД_МодификацияУправляемойФормы.Создать();
	
	Если МетаданныеМакета.ТипМакета = Метаданные.СвойстваОбъектов.ТипМакета.ТабличныйДокумент Тогда
		Возврат ОбработкаКонвертации.ПреобразоватьТабличныйДокументВJSON(ДанныеМакета);
	Иначе
		ТабличныйДокумент = ОбработкаКонвертации.ПреобразоватьJSONВТабличныйДокумент(ДанныеМакета);
		Возврат ОбработкаКонвертации.ПреобразоватьТабличныйДокументВJSON(ТабличныйДокумент);
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура ВыгрузитьМакеты(СтруктураПараметры, ОбработчикЗавершения)
	ОбновитьСостояниеВыполнения(НСтр("ru = 'Выгрузка макетов'"));
	
	ПутьКСпискуФайлов = ДобавитьРазделительПути(СтруктураПараметры.РабочийКаталог) + "export.txt";
	ПутьКЛогу = ДобавитьРазделительПути(СтруктураПараметры.РабочийКаталог) + "log.txt";
	
	МакетыДляВыгрузки = Новый Массив;
	Для Каждого ОписаниеМакета Из СтруктураПараметры.ОписанияМакетов Цикл
		МакетыДляВыгрузки.Добавить(ОписаниеМакета.ПолноеИмя);
	КонецЦикла;
	
	ЗаписьТекста = Новый ЗаписьТекста(ПутьКСпискуФайлов, "UTF-8");
	ЗаписьТекста.Записать(СтрСоединить(МакетыДляВыгрузки, Символы.ПС));
	ЗаписьТекста.Закрыть();
	
	МассивКоманда = Новый Массив;
	МассивКоманда.Добавить(ДобавитьРазделительПути(КаталогПрограммы()) + "1cv8.exe");
	МассивКоманда.Добавить("DESIGNER");
	МассивКоманда.Добавить(СтрШаблон("/IBConnectionString %1", СтрокаСоединенияИнформационнойБазы()));
	Если ЗначениеЗаполнено(ИмяПользователя) Тогда
		МассивКоманда.Добавить(СтрШаблон("/N %1", ИмяПользователя));
	КонецЕсли;
	Если ЗначениеЗаполнено(Пароль) Тогда
		МассивКоманда.Добавить(СтрШаблон("/P %1", Пароль));
	КонецЕсли;
	
	МассивКоманда.Добавить(СтрШаблон("/Out %1", ПутьКЛогу));
	МассивКоманда.Добавить("/DisableStartupDialogs");
	МассивКоманда.Добавить(СтрШаблон("/DumpConfigToFiles %1", СтруктураПараметры.РабочийКаталог));
	МассивКоманда.Добавить(СтрШаблон("-listFile %1", ПутьКСпискуФайлов));
	
	ПараметрыВызова = Новый Структура("РабочийКаталог,ОбработчикЗавершения,ПутьКЛогу", СтруктураПараметры.РабочийКаталог, ОбработчикЗавершения, ПутьКЛогу);
	
	ОбработчикПродолжения = Новый ОписаниеОповещения("ВыгрузитьМакетыПослеВыгрузки", ЭтаФорма, ПараметрыВызова);
	НачатьЗапускПриложения(ОбработчикПродолжения, СтрСоединить(МассивКоманда, " "), , Истина);
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьМакетыПослеВыгрузки(КодВозврата, ДополнительныеПараметры) Экспорт
	Если КодВозврата > 0 Тогда
		ЧтениеТекста = Новый ЧтениеТекста;
		ЧтениеТекста.Открыть(ДополнительныеПараметры.ПутьКЛогу);
		ТекстСообщения = ЧтениеТекста.Прочитать();
		Если ЗначениеЗаполнено(ТекстСообщения) Тогда
			Сообщить(ТекстСообщения);
		КонецЕсли;
		НачатьУдалениеФайлов( , ДополнительныеПараметры.РабочийКаталог);
		ОбновитьСостояниеВыполнения();
		Возврат;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработчикЗавершения, КодВозврата);
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьМакеты(СтруктураПараметры, ПутьКСпискуФайлов)
	ОбновитьСостояниеВыполнения(НСтр("ru = 'Загрузка макетов'"));
	
	ПутьКЛогу = ДобавитьРазделительПути(СтруктураПараметры.РабочийКаталог) + "log.txt";
	
	МассивКоманда = Новый Массив;
	МассивКоманда.Добавить(ДобавитьРазделительПути(КаталогПрограммы()) + "1cv8.exe");
	МассивКоманда.Добавить("DESIGNER");
	МассивКоманда.Добавить(СтрШаблон("/IBConnectionString %1", СтрокаСоединенияИнформационнойБазы()));
	Если ЗначениеЗаполнено(ИмяПользователя) Тогда
		МассивКоманда.Добавить(СтрШаблон("/N %1", ИмяПользователя));
	КонецЕсли;
	Если ЗначениеЗаполнено(Пароль) Тогда
		МассивКоманда.Добавить(СтрШаблон("/P %1", Пароль));
	КонецЕсли;
	
	МассивКоманда.Добавить(СтрШаблон("/Out %1", ПутьКЛогу));
	МассивКоманда.Добавить("/DisableStartupDialogs");
	МассивКоманда.Добавить(СтрШаблон("/LoadConfigFromFiles %1", СтруктураПараметры.РабочийКаталог));
	МассивКоманда.Добавить(СтрШаблон("-listFile %1", ПутьКСпискуФайлов));
	
	ПараметрыВызова = Новый Структура("РабочийКаталог,ПутьКЛогу", СтруктураПараметры.РабочийКаталог, ПутьКЛогу);
	
	ОбработчикПродолжения = Новый ОписаниеОповещения("ЗагрузитьМакетыПослеЗагрузки", ЭтаФорма, ПараметрыВызова);
	НачатьЗапускПриложения(ОбработчикПродолжения, СтрСоединить(МассивКоманда, " "), , Истина);
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьМакетыПослеЗагрузки(КодВозврата, ДополнительныеПараметры) Экспорт
	Если КодВозврата > 0 Тогда
		ЧтениеТекста = Новый ЧтениеТекста;
		ЧтениеТекста.Открыть(ДополнительныеПараметры.ПутьКЛогу);
		ТекстСообщения = ЧтениеТекста.Прочитать();
		Если ЗначениеЗаполнено(ТекстСообщения) Тогда
			Сообщить(ТекстСообщения);
		КонецЕсли;
		НачатьУдалениеФайлов( , ДополнительныеПараметры.РабочийКаталог);
		ОбновитьСостояниеВыполнения();
		Возврат;
	КонецЕсли;
	
	ОбновитьСостояниеВыполнения(НСтр("ru = 'Макеты загружены'"));
	НачатьУдалениеФайлов( , ДополнительныеПараметры.РабочийКаталог);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСостояниеВыполнения(Состояние = Неопределено, Процент = Неопределено)
	Если Состояние = Неопределено Тогда
		Элементы.ГруппаВыполнение.Видимость = Ложь;
		Возврат;
	КонецЕсли;
	
	Элементы.ГруппаВыполнение.Видимость = Истина;
	Элементы.СостояниеВыполнения.Заголовок = Состояние;
	Элементы.ПроцентВыполнения.Видимость = (Процент <> Неопределено);
	
	ПроцентВыполнения = Процент;
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ДобавитьРазделительПути(Путь)
	Если Прав(Путь, 1) = ПолучитьРазделительПути() Тогда
		Возврат Путь;
	Иначе
		Возврат Путь + ПолучитьРазделительПути();
	КонецЕсли;
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьОписанияМакетовИзменений(РабочийКаталог)
	МакетыИзменений = Новый Массив;
	СоответсвиеИмен = ДанныеСоответствияИмен();
	
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
				МетаданныеМакета = ОбъектМетаданных.Макеты.Найти(ИмяМакетаИзменений);
				Если МетаданныеМакета <> Неопределено Тогда
					ДобавитьИнформациюОМакете(МакетыИзменений, СоответсвиеИмен, РабочийКаталог, МетаданныеМакета);
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Для Каждого МетаданныеФормы Из Метаданные.ОбщиеФормы Цикл
		ИмяМакетаИзменений = "МОД_Модификация_" + МетаданныеФормы.Имя;
		МетаданныеМакета = Метаданные.ОбщиеМакеты.Найти(ИмяМакетаИзменений);
		Если МетаданныеМакета <> Неопределено Тогда
			ДобавитьИнформациюОМакете(МакетыИзменений, СоответсвиеИмен, РабочийКаталог, МетаданныеМакета);
		КонецЕсли;
	КонецЦикла;
	
	Возврат МакетыИзменений;
КонецФункции

&НаСервереБезКонтекста
Процедура ДобавитьИнформациюОМакете(МакетыИзменений, СоответсвиеИмен, РабочийКаталог, МетаданныеМакета)
	Если МетаданныеМакета.ТипМакета = Метаданные.СвойстваОбъектов.ТипМакета.ТабличныйДокумент Тогда
		РасширениеФайлаМакета = "xml";
	ИначеЕсли МетаданныеМакета.ТипМакета = Метаданные.СвойстваОбъектов.ТипМакета.ТекстовыйДокумент Тогда
		РасширениеФайлаМакета = "txt";
	Иначе
		Возврат;
	КонецЕсли;
	
	ПолноеИмя = МетаданныеМакета.ПолноеИмя();
	
	Путь = СтрРазделить(ПолноеИмя, ".");
	Путь[0] = ПолучитьПоСоответствию(СоответсвиеИмен, Путь[0], "ЭлементРус", "КоллекцияАнгл");
	Если Путь.Количество() > 2 Тогда
		Путь[2] = "Templates";
	КонецЕсли;
	
	ПутьКОбъекту = ДобавитьРазделительПути(РабочийКаталог) + СтрСоединить(Путь, ПолучитьРазделительПути()) + ".xml";
	ПутьКМакету = ДобавитьРазделительПути(РабочийКаталог) + СтрСоединить(Путь, ПолучитьРазделительПути())
		+ ПолучитьРазделительПути() + "Ext" + ПолучитьРазделительПути() + "Template." + РасширениеФайлаМакета;
		
	МакетыИзменений.Добавить(Новый Структура("ПолноеИмя,ПутьКОбъекту,ПутьКМакету"
	    ,ПолноеИмя
		,ПутьКОбъекту
		,ПутьКМакету)
		);
КонецПроцедуры

&НаСервереБезКонтекста
Функция МенеджерПоПолномуИмени(ПолноеИмя = Неопределено)
	МассивРезультат = Новый Массив;
	Если ПолноеИмя <> Неопределено Тогда
		ЧастиИмени = СтрРазделить(ПолноеИмя, ".");
		КлассОМ = ВРег(ЧастиИмени[0]);
	Иначе
		ЧастиИмени = Новый Массив;
		КлассОМ = Неопределено;
	КонецЕсли;
	
	Если ЧастиИмени.Количество() > 1 Тогда
		ИмяОМ = ЧастиИмени[1];
	Иначе
		ИмяОМ = Неопределено;
	КонецЕсли;
	
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ПЛАНОБМЕНА", ПланыОбмена);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "СПРАВОЧНИК", Справочники);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ДОКУМЕНТ", Документы);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ЖУРНАЛДОКУМЕНТОВ", ЖурналыДокументов, Ложь);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ПЕРЕЧИСЛЕНИЕ", Перечисления);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ОТЧЕТ", Отчеты, Ложь);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ОБРАБОТКА", Обработки, Ложь);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ПЛАНВИДОВХАРАКТЕРИСТИК", ПланыВидовХарактеристик);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ПЛАНСЧЕТОВ", ПланыСчетов);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ПЛАНВИДОВРАСЧЕТА", ПланыВидовРасчета);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "РЕГИСТРСВЕДЕНИЙ", РегистрыСведений, Ложь);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "РЕГИСТРНАКОПЛЕНИЯ", РегистрыНакопления, Ложь);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "РЕГИСТРБУХГАЛТЕРИИ", РегистрыБухгалтерии, Ложь);
	
	Если КлассОМ = "РЕГИСТРРАСЧЕТА" Тогда
		Если ЧастиИмени.Количество() = 2 Тогда
			МассивРезультат.Добавить(РегистрыРасчета);
			
		ИначеЕсли ЧастиИмени.Количество() = 4 Тогда
			Если ВРег(ЧастиИмени[2]) = "ПЕРЕРАСЧЕТ" Тогда
				МассивРезультат.Добавить(РегистрыРасчета[ИмяОМ].Перерасчеты);
				ИмяОМ = ЧастиИмени[3];
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "БИЗНЕСПРОЦЕСС", БизнесПроцессы);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ЗАДАЧА", Задачи);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "КОНСТАНТА", Константы, Ложь);
	ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, "ПОСЛЕДОВАТЕЛЬНОСТЬ", Последовательности, Ложь);
	
	Если КлассОМ = Неопределено Тогда
		Для Каждого МетаданныеОбъекта Из Метаданные.ВнешниеИсточникиДанных Цикл
			МассивРезультат.Добавить(ВнешниеИсточникиДанных[МетаданныеОбъекта.Имя].Таблицы);
		КонецЦикла;
	КонецЕсли;
	
	Если МассивРезультат.Количество() = 0 Тогда
		ВызватьИсключение СтрШаблон(НСтр("ru = 'Объект метаданных %1 не найден'"), ПолноеИмя);
	Иначе
		Если ИмяОМ <> Неопределено Тогда
			Возврат МассивРезультат[0][ИмяОМ];
			
		ИначеЕсли КлассОМ <> Неопределено Тогда
			Возврат МассивРезультат[0]	
			
		Иначе
			Возврат МассивРезультат;
		КонецЕсли;
	КонецЕсли;
КонецФункции

&НаСервереБезКонтекста
Процедура ДобавитьМенеджерОбъектовМетаданных(МассивРезультат, КлассОМ, Имя, Менеджер, ЕстьСсылки = Истина)
	Если КлассОМ = Неопределено
		И ЕстьСсылки
		ИЛИ КлассОМ = Имя Тогда
		
		МассивРезультат.Добавить(Менеджер);
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДанныеСоответствияИмен()
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("КоллекцияАнгл");
	Результат.Колонки.Добавить("ЭлементАнгл");
	Результат.Колонки.Добавить("КоллекцияРус");
	Результат.Колонки.Добавить("ЭлементРус");
	
	ДобавитьСоответсвиеИмен(Результат,"AccountingRegisters", "AccountingRegister", "РегистрыБухгалтерии", "РегистрБухгалтерии");
    ДобавитьСоответсвиеИмен(Результат,"AccumulationRegisters", "AccumulationRegister", "РегистрыНакопления", "РегистрНакопления");
    ДобавитьСоответсвиеИмен(Результат,"BusinessProcesses", "BusinessProcess", "БизнесПроцессы", "БизнесПроцесс");
    ДобавитьСоответсвиеИмен(Результат,"CalculationRegisters", "CalculationRegister", "РегистрыРасчета", "РегистрРасчета");
    ДобавитьСоответсвиеИмен(Результат,"Catalogs", "Catalog", "Справочники", "Справочник");
    ДобавитьСоответсвиеИмен(Результат,"ChartsOfAccounts", "ChartOfAccounts", "ПланыСчетов", "ПланСчетов");
    ДобавитьСоответсвиеИмен(Результат,"ChartsOfCalculationTypes", "ChartOfCalculationTypes", "ПланыВидовРасчета", "ПланВидовРасчета");
    ДобавитьСоответсвиеИмен(Результат,"ChartsOfCharacteristicTypes", "ChartOfCharacteristicTypes","ПланыВидовХарактеристик", "ПланВидовХарактеристик");
    ДобавитьСоответсвиеИмен(Результат,"CommandGroups", "CommandGroup", "ГруппыКоманд", "ГруппаКоманд");
    ДобавитьСоответсвиеИмен(Результат,"CommonAttributes", "CommonAttribute", "ОбщиеРеквизиты", "ОбщийРеквизит");
    ДобавитьСоответсвиеИмен(Результат,"CommonCommands", "CommonCommand", "ОбщиеКоманды", "ОбщаяКоманда");
    ДобавитьСоответсвиеИмен(Результат,"CommonForms", "CommonForm", "ОбщиеФормы", "ОбщаяФорма");
    ДобавитьСоответсвиеИмен(Результат,"CommonModules", "CommonModule", "ОбщиеМодули", "ОбщийМодуль");
    ДобавитьСоответсвиеИмен(Результат,"CommonPictures", "CommonPicture", "ОбщиеКартинки", "ОбщаяКартинка");
    ДобавитьСоответсвиеИмен(Результат,"CommonTemplates", "CommonTemplate", "ОбщиеМакеты", "ОбщийМакет");
    ДобавитьСоответсвиеИмен(Результат,"Constants", "Constant", "Константы", "Константа");
    ДобавитьСоответсвиеИмен(Результат,"DataProcessors", "DataProcessor", "Обработки", "Обработка");
    ДобавитьСоответсвиеИмен(Результат,"DefinedTypes", "DefinedType", "ОпределяемыеТипы", "ОпределяемыйТип");
    ДобавитьСоответсвиеИмен(Результат,"DocumentJournals", "DocumentJournal", "ЖурналыДокументов", "ЖурналДокументов");
    ДобавитьСоответсвиеИмен(Результат,"DocumentNumerators", "DocumentNumerator", "НумераторыДокументов", "НумераторДокументов");
    ДобавитьСоответсвиеИмен(Результат,"Documents", "Document", "Документы", "Документ");
    ДобавитьСоответсвиеИмен(Результат,"Enums", "Enum", "Перечисления", "Перечисление");
    ДобавитьСоответсвиеИмен(Результат,"EventSubscriptions", "EventSubscription", "ПодпискиНаСобытия", "ПодпискаНаСобытие");
    ДобавитьСоответсвиеИмен(Результат,"ExchangePlans", "ExchangePlan", "ПланыОбмена", "ПланОбмена");
    ДобавитьСоответсвиеИмен(Результат,"ExternalDataSources", "ExternalDataSource", "ВнешниеИсточникиДанных", "ВнешнийИсточникДанных");
    ДобавитьСоответсвиеИмен(Результат,"FilterCriteria", "FilterCriterion", "КритерииОтбора", "КритерийОтбора");
    ДобавитьСоответсвиеИмен(Результат,"FunctionalOptions", "FunctionalOption", "ФункциональныеОпции", "ФункциональнаяОпция");
    ДобавитьСоответсвиеИмен(Результат,"FunctionalOptionsParameters", "FunctionalOptionsParameter","ПараметрыФункциональныхОпций", "ПараметрФункциональнойОпции");
    ДобавитьСоответсвиеИмен(Результат,"HTTPServices", "HTTPService", "HTTPСервисы", "HTTPСервис");
    ДобавитьСоответсвиеИмен(Результат,"InformationRegisters", "InformationRegister", "РегистрыСведений", "РегистрСведений");
    ДобавитьСоответсвиеИмен(Результат,"Languages", "Language", "Языки", "Язык");
    ДобавитьСоответсвиеИмен(Результат,"Reports", "Report", "Отчеты", "Отчет");
    ДобавитьСоответсвиеИмен(Результат,"Roles", "Role", "Роли", "Роль");
    ДобавитьСоответсвиеИмен(Результат,"ScheduledJobs", "ScheduledJob", "РегламентныеЗадания", "РегламентноеЗадание");
    ДобавитьСоответсвиеИмен(Результат,"Sequences", "Sequence", "Последовательности", "Последовательность");
    ДобавитьСоответсвиеИмен(Результат,"SessionParameters", "SessionParameter", "ПараметрыСеанса", "ПараметрСеанса");
    ДобавитьСоответсвиеИмен(Результат,"SettingsStorages", "SettingsStorage", "ХранилищаНастроек", "ХранилищеНастроек");
    ДобавитьСоответсвиеИмен(Результат,"StyleItems", "StyleItem", "ЭлементыСтиля", "ЭлементСтиля");
    ДобавитьСоответсвиеИмен(Результат,"Styles", "Style", "Стили", "Стиль");
    ДобавитьСоответсвиеИмен(Результат,"Subsystems", "Subsystem", "Подсистемы", "Подсистема");
    ДобавитьСоответсвиеИмен(Результат,"Tasks", "Task", "Задачи", "Задача");
    ДобавитьСоответсвиеИмен(Результат,"WebServices", "WebService", "WebСервисы", "WebСервис");
    ДобавитьСоответсвиеИмен(Результат,"WSReferences", "WSReference", "WSСсылки", "WSСсылка");
    ДобавитьСоответсвиеИмен(Результат,"XDTOPackages", "XDTOPackage", "ПакетыXDTO", "ПакетXDTO");
	
	Возврат Результат;

КонецФункции

&НаСервереБезКонтекста
Процедура ДобавитьСоответсвиеИмен(Результат, КоллекцияАнгл, ЭлементАнгл, КоллекцияРус, ЭлементРус)
	НоваяСтрока = Результат.Добавить();
	НоваяСтрока.КоллекцияАнгл = КоллекцияАнгл;
	НоваяСтрока.ЭлементАнгл = ЭлементАнгл;
	НоваяСтрока.КоллекцияРус = КоллекцияРус;
	НоваяСтрока.ЭлементРус = ЭлементРус;
КонецПроцедуры 

&НаСервереБезКонтекста
Функция ПолучитьПоСоответствию(ТаблицаСоответствие, Значение, КолонкаИсточник, КолонкаРезультат)
	СтрокаТаблицы = ТаблицаСоответствие.Найти(Значение, КолонкаИсточник);
	Возврат СтрокаТаблицы[КолонкаРезультат];
КонецФункции