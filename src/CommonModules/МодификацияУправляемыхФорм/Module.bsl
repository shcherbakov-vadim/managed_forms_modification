///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, Щербаков Вадим, chtcherbakov.vadim@gmail.com
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by-sa/4.0/legalcode
// Ссылка на репозитарий:
// https://github.com/shcherbakov-vadim/managed_forms_modification.git

Процедура ПрименитьМакетИзменений(Форма) Экспорт
	МакетИзменений = Неопределено;
	
	МассивПуть = СтрРазделить(Форма.ИмяФормы, ".");
	Если МассивПуть.Количество() = 4 Тогда
		ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(МассивПуть[0] + "." + МассивПуть[1]);
		Если ОбъектМетаданных <> Неопределено Тогда
			Если ОбъектМетаданных.Макеты.Найти("МОД_Модификация_" + МассивПуть[3]) <> Неопределено Тогда
				МенеджерОбъекта = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(МассивПуть[0] + "." + МассивПуть[1]);
				МакетИзменений = МенеджерОбъекта.ПолучитьМакет("МОД_Модификация_" + МассивПуть[3]);
			КонецЕсли;
		КонецЕсли;
		
	ИначеЕсли МассивПуть.Количество() = 2 Тогда
		Если Метаданные.ОбщиеМакеты.Найти("МОД_Модификация_" + МассивПуть[1]) <> Неопределено Тогда
			МакетИзменений = ПолучитьОбщийМакет("МОД_Модификация_" + МассивПуть[1]);
		КонецЕсли;
	КонецЕсли;
	
	Если МакетИзменений = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	
	СтруктураЗначения = Новый Структура("МОД_МодификацияУправляемыхФорм");
	ЗаполнитьЗначенияСвойств(СтруктураЗначения, Форма);
	
	Если СтруктураЗначения.МОД_МодификацияУправляемыхФорм <> Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	МассивДобавляемыеРеквизиты = Новый Массив;
	МассивДобавляемыеРеквизиты.Добавить(Новый РеквизитФормы("МОД_МодификацияУправляемыхФорм", Новый ОписаниеТипов("Булево")));
	Форма.ИзменитьРеквизиты(МассивДобавляемыеРеквизиты);
	
	Если МакетИзменений.Области.Найти("Реквизиты") <> Неопределено Тогда
		ИзменитьРеквизиты(Форма, МакетИзменений.ПолучитьОбласть("Реквизиты"));
	КонецЕсли;
	
	Если МакетИзменений.Области.Найти("Команды") <> Неопределено Тогда
		ИзменитьКоманды(Форма, МакетИзменений.ПолучитьОбласть("Команды"));
	КонецЕсли;
	
	Если МакетИзменений.Области.Найти("Элементы") <> Неопределено Тогда
		ИзменитьЭлементы(Форма, МакетИзменений.ПолучитьОбласть("Элементы"));
	КонецЕсли;
КонецПроцедуры

Процедура ИзменитьРеквизиты(Форма, МакетИзменений, ШиринаИмени = Неопределено, НомСтроки = 2, НомКолонки = 1, ИмяРодителя = Неопределено)
	Если ШиринаИмени = Неопределено Тогда
		// расчет ширины имени
		ШиринаИмени = 0;
		Для Инд = 1 По МакетИзменений.ШиринаТаблицы Цикл
			Если МакетИзменений.Область(1, Инд).Текст = "Имя" Тогда
				ШиринаИмени = Инд;
			Иначе
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ИмяРеквизита = МакетИзменений.Область(НомСтроки, НомКолонки).Текст;
	Если НЕ ЗначениеЗаполнено(ИмяРеквизита) Тогда
		Возврат;
	КонецЕсли;
	
	МассивРеквизиты = Форма.ПолучитьРеквизиты(ИмяРодителя);
	СоответствиеРеквизиты = Новый Соответствие;
	Для Каждого РеквизитФормы Из МассивРеквизиты Цикл
		СоответствиеРеквизиты.Вставить(РеквизитФормы.Имя, РеквизитФормы);
	КонецЦикла;
	
	СвойстваРеквизитов = Неопределено;
	МассивДобавляемыеРеквизиты = Новый Массив;
	Пока Истина Цикл
		СтруктураСвойства = Новый Структура;
		Для Инд = ШиринаИмени + 1 По МакетИзменений.ШиринаТаблицы Цикл
			Если ЗначениеЗаполнено(МакетИзменений.Область(НомСтроки, Инд).Текст) Тогда
				ИмяСвойства = МакетИзменений.Область(1, Инд).Текст;
				ОписаниеЗначения = МакетИзменений.Область(НомСтроки, Инд).Текст;
				
				Поз = Найти(ИмяСвойства, "(");
				Если Поз > 0 Тогда
					ИмяОбработчика = Лев(ИмяСвойства, Поз - 1);
					ИмяПараметра = Сред(ИмяСвойства, Поз + 1, СтрДлина(ИмяСвойства) - Поз - 1);
					Если НЕ ЗначениеЗаполнено(ИмяПараметра) Тогда
						ИмяПараметра = ИмяОбработчика;
					КонецЕсли;
					
					Если ЗначениеЗаполнено(ИмяОбработчика) Тогда
						Результат = ВычислитьЗначениеНастройки(ИмяОбработчика, ОписаниеЗначения);
					Иначе
						Результат = Вычислить(ОписаниеЗначения);
					КонецЕсли;
					
					Если Найти(ИмяПараметра, ".") > 0 Тогда
						ДобавитьЗначениеСвойства(СвойстваРеквизитов, ИмяРеквизита + ИмяПараметра, Результат);
					Иначе
						СтруктураСвойства.Вставить(ИмяПараметра, Результат);
					КонецЕсли;
				Иначе
					Если Найти(ИмяСвойства, ".") > 0 Тогда
						ДобавитьЗначениеСвойства(СвойстваРеквизитов, ИмяРеквизита + ИмяСвойства, ОписаниеЗначения);
					Иначе
						СтруктураСвойства.Вставить(ИмяСвойства, ОписаниеЗначения);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		РеквизитФормы = СоответствиеРеквизиты[ИмяРеквизита];
		Если РеквизитФормы = Неопределено Тогда
			Если СтруктураСвойства.Свойство("ТипЗначения") Тогда
				РеквизитФормы = Новый РеквизитФормы(ИмяРеквизита, СтруктураСвойства.ТипЗначения, ИмяРодителя);
			Иначе
				РеквизитФормы = Новый РеквизитФормы(ИмяРеквизита, Новый ОписаниеТипов, ИмяРодителя);
			КонецЕсли;
			
			МассивДобавляемыеРеквизиты.Добавить(РеквизитФормы);	
		КонецЕсли;
			
		ЗаполнитьЗначенияСвойств(РеквизитФормы, СтруктураСвойства);
		
		НомСтроки = НомСтроки + 1;
		Если НомСтроки > МакетИзменений.ВысотаТаблицы Тогда
			Прервать;
		КонецЕсли;
		
		ТекстЯчейки = МакетИзменений.Область(НомСтроки, НомКолонки).Текст;
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Если НомКолонки < ШиринаИмени Тогда
				Форма.ИзменитьРеквизиты(МассивДобавляемыеРеквизиты);
				МассивДобавляемыеРеквизиты.Очистить();
				
				ИзменитьРеквизиты(Форма, МакетИзменений, ШиринаИмени, НомСтроки, НомКолонки + 1, ?(ИмяРодителя = Неопределено, ИмяРеквизита, ИмяРодителя + "." + ИмяРеквизита));
			КонецЕсли;
			
			ТекстЯчейки = МакетИзменений.Область(НомСтроки, НомКолонки).Текст;
			Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
		
		ИмяРеквизита = ТекстЯчейки;
	КонецЦикла;
	
	Форма.ИзменитьРеквизиты(МассивДобавляемыеРеквизиты);
	УстановитьЗначенияСвойств(Форма, СвойстваРеквизитов);
КонецПроцедуры

Процедура ДобавитьЗначениеСвойства(ТаблицаРезультат, Путь, Значение)
	Если ТаблицаРезультат = Неопределено Тогда
		ТаблицаРезультат = Новый ТаблицаЗначений;
		ТаблицаРезультат.Колонки.Добавить("Путь");
		ТаблицаРезультат.Колонки.Добавить("ДлинаПути");
		ТаблицаРезультат.Колонки.Добавить("МассивПуть");
		ТаблицаРезультат.Колонки.Добавить("Свойства", Новый ОписаниеТипов("Структура"));
	КонецЕсли;
	
	МассивПуть = СтрРазделить(Путь, ".");
	ИмяСвойства = МассивПуть[МассивПуть.Количество() - 1];
	МассивПуть.Удалить(МассивПуть.Количество() - 1);
	Путь = СтрРазделить(МассивПуть, ".");
	
	СтрокаРезультата = ТаблицаРезультат.Найти(Путь, "Путь");
	Если СтрокаРезультата = Неопределено Тогда
		СтрокаРезультата = ТаблицаРезультат.Добавить();
		СтрокаРезультата.Путь = Путь;
		СтрокаРезультата.МассивПуть = МассивПуть;
		СтрокаРезультата.ДлинаПути = МассивПуть.Количество();
	КонецЕсли;
		
	СтрокаРезультата.Свойства.Вставить(ИмяСвойства, Значение);
КонецПроцедуры

Процедура УстановитьЗначенияСвойств(Форма, ТаблицаРезультат)
	Если ТаблицаРезультат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаРезультат.Сортировать("ДлинаПути");
	Для Каждого СтрокаТаблицы Из ТаблицаРезультат Цикл
		ТекущийКонтекст = Форма;
		Для Каждого ЭлементПути Из СтрокаТаблицы.МассивПуть Цикл
			ТекущийКонтекст = ТекущийКонтекст[ЭлементПути];
		КонецЦикла;
		
		ЗаполнитьЗначенияСвойств(ТекущийКонтекст, СтрокаТаблицы.Свойства);
	КонецЦикла;
КонецПроцедуры

Процедура ИзменитьКоманды(Форма, МакетИзменений)
	Для НомСтроки = 2 По МакетИзменений.ВысотаТаблицы Цикл
		ИмяКоманды = МакетИзменений.Область(НомСтроки, 1).Текст;
		Если НЕ ЗначениеЗаполнено(ИмяКоманды) Тогда
			Возврат;
		КонецЕсли;
		
		СтруктураСвойства = Новый Структура;
		Для Инд = 2 По МакетИзменений.ШиринаТаблицы Цикл
			Если ЗначениеЗаполнено(МакетИзменений.Область(НомСтроки, Инд).Текст) Тогда
				ИмяСвойства = МакетИзменений.Область(1, Инд).Текст;
				ОписаниеЗначения = МакетИзменений.Область(НомСтроки, Инд).Текст;
				
				Поз = Найти(ИмяСвойства, "(");
				Если Поз > 0 Тогда
					ИмяОбработчика = Лев(ИмяСвойства, Поз - 1);
					ИмяПараметра = Сред(ИмяСвойства, Поз + 1, СтрДлина(ИмяСвойства) - Поз - 1);
					Если НЕ ЗначениеЗаполнено(ИмяПараметра) Тогда
						ИмяПараметра = ИмяОбработчика;
					КонецЕсли;
					
					Если ЗначениеЗаполнено(ИмяОбработчика) Тогда
						Результат = ВычислитьЗначениеНастройки(ИмяОбработчика, ОписаниеЗначения);
					Иначе
						Результат = Вычислить(ОписаниеЗначения);
					КонецЕсли;
					
					СтруктураСвойства.Вставить(ИмяПараметра, Результат);
				Иначе
					СтруктураСвойства.Вставить(ИмяСвойства, ОписаниеЗначения);
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		Команда = Форма.Команды.Найти(ИмяКоманды);
		Если Команда = Неопределено Тогда
			Команда = Форма.Команды.Добавить(ИмяКоманды);
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Команда, СтруктураСвойства);
	КонецЦикла;
КонецПроцедуры

Процедура ИзменитьЭлементы(Форма, МакетИзменений, ШиринаИмени = Неопределено, НомСтроки = 2, НомКолонки = 1, ИмяРодителя = Неопределено)
	Если ШиринаИмени = Неопределено Тогда
		// расчет ширины имени
		ШиринаИмени = 0;
		Для Инд = 1 По МакетИзменений.ШиринаТаблицы Цикл
			Если МакетИзменений.Область(1, Инд).Текст = "Имя" Тогда
				ШиринаИмени = Инд;
			Иначе
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	ИмяЭлемента = МакетИзменений.Область(НомСтроки, НомКолонки).Текст;
	Если НЕ ЗначениеЗаполнено(ИмяЭлемента) Тогда
		Возврат;
	КонецЕсли;
	
	ЭлементРодитель = ?(ИмяРодителя = Неопределено, Неопределено, Форма.Элементы[ИмяРодителя]);
	
	СоответствиеПрефиксы = Новый Соответствие;
	Пока Истина Цикл
		Если Найти(ИмяЭлемента, "%") > 0 Тогда
			ИмяЭлемента = СтрЗаменить(ИмяЭлемента, "%", ИмяРодителя);
		КонецЕсли;
		
		Если ИмяЭлемента = "Форма" Тогда
			Элемент = Форма;
		Иначе
			Элемент = Форма.Элементы.Найти(ИмяЭлемента);
		КонецЕсли;
		
		СтруктураСвойства = Новый Структура;
		СтруктураДействия = Новый Структура;
		СтруктураОперации = Новый Структура;
		Для Инд = ШиринаИмени + 1 По МакетИзменений.ШиринаТаблицы Цикл
			Если ЗначениеЗаполнено(МакетИзменений.Область(НомСтроки, Инд).Текст) Тогда
				ИмяСвойства = МакетИзменений.Область(1, Инд).Текст;
				ОписаниеЗначения = МакетИзменений.Область(НомСтроки, Инд).Текст;
				
				Если Лев(ИмяСвойства, 1) = "[" Тогда
					ИмяДействия = Сред(ИмяСвойства, 2, СтрДлина(ИмяСвойства) - 2);
					Если ОписаниеЗначения = "%" Тогда
						ОписаниеЗначения = ИмяЭлемента + ИмяДействия;
					ИначеЕсли Найти(ОписаниеЗначения, "%") > 0 Тогда
						ОписаниеЗначения = СтрЗаменить(ОписаниеЗначения, "%", ИмяДействия);
					КонецЕсли;
					
					СтруктураДействия.Вставить(ИмяДействия, ОписаниеЗначения);
				Иначе
					Поз = Найти(ИмяСвойства, "(");
					Если Поз > 0 Тогда
						ИмяОбработчика = Лев(ИмяСвойства, Поз - 1);
						ИмяПараметра = Сред(ИмяСвойства, Поз + 1, СтрДлина(ИмяСвойства) - Поз - 1);
						Если НЕ ЗначениеЗаполнено(ИмяПараметра) Тогда
							ИмяПараметра = ИмяОбработчика;
						КонецЕсли;
						
						ТекущееЗначение = ?(Элемент <> Неопределено, Элемент[ИмяПараметра], Неопределено);
						
						Если ИмяОбработчика = "МестоРасположения" Тогда
							СтруктураОперации.Вставить(ИмяОбработчика, ОписаниеЗначения);
						ИначеЕсли ЗначениеЗаполнено(ИмяОбработчика) Тогда
							Результат = ВычислитьЗначениеНастройки(ИмяОбработчика, ОписаниеЗначения, ТекущееЗначение);
						Иначе
							Результат = Вычислить(ОписаниеЗначения);
						КонецЕсли;
						
						СтруктураСвойства.Вставить(ИмяПараметра, Результат);
					Иначе
						Если Найти(ОписаниеЗначения, "%") > 0 Тогда
							ОписаниеЗначения = СтрЗаменить(ОписаниеЗначения, "%", ЭлементРодитель[ИмяСвойства]);
						КонецЕсли;
						
						СтруктураСвойства.Вставить(ИмяСвойства, ОписаниеЗначения);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		
		Если Элемент = Неопределено Тогда
			Элемент = Форма.Элементы.Добавить(ИмяЭлемента, Тип(СтруктураСвойства.Тип), ЭлементРодитель);
			
			Реквизит = Неопределено;
			Если СтруктураСвойства.Свойство("ПутьКДанным") Тогда
				Поз = Найти(СтруктураСвойства.ПутьКДанным, "/");
				Если Поз > 0 Тогда
					ПутьКРеквизиту = Лев(СтруктураСвойства.ПутьКДанным, Поз - 1);
					ПоляРеквизита = Сред(СтруктураСвойства.ПутьКДанным, Поз + 1);
				Иначе
					ПутьКРеквизиту = СтруктураСвойства.ПутьКДанным;
					ПоляРеквизита = "";
				КонецЕсли;
					
				ПутьКРеквизитуРаздельно = СтрЗаменить(ПутьКРеквизиту, ".", Символы.ПС);
				КоличествоРазделов = СтрЧислоСтрок(ПутьКРеквизитуРаздельно);
				Если КоличествоРазделов > 1 Тогда
					Имя = СтрПолучитьСтроку(ПутьКРеквизитуРаздельно, КоличествоРазделов);
					Префикс = Лев(ПутьКРеквизиту, СтрДлина(ПутьКРеквизиту) - СтрДлина(Имя) - 1);
						
				Иначе
					Имя = ПутьКРеквизиту;
					Префикс = "";
				КонецЕсли;
				
				СоответствиеРеквизиты = СоответствиеПрефиксы[Префикс];
				Если СоответствиеРеквизиты = Неопределено Тогда
					СоответствиеРеквизиты = Новый Соответствие;
					Для Каждого Реквизит Из Форма.ПолучитьРеквизиты(Префикс) Цикл
						СоответствиеРеквизиты.Вставить(Реквизит.Имя, Реквизит);
					КонецЦикла;
					
					СоответствиеПрефиксы.Вставить(Префикс, СоответствиеРеквизиты);
				КонецЕсли;
				
				Если ЗначениеЗаполнено(ПоляРеквизита) Тогда
					Если СоответствиеРеквизиты[Имя].ТипЗначения.Типы().Количество() = 1 Тогда
						ЕстьОшибки = Ложь;
						ОписаниеТипов = СоответствиеРеквизиты[Имя].ТипЗначения;
						
						ПоляРеквизитаРаздельно = СтрЗаменить(ПоляРеквизита, ".", Символы.ПС);
						Для Инд = 1 По СтрЧислоСтрок(ПоляРеквизитаРаздельно) Цикл
							Имя = СтрПолучитьСтроку(ПоляРеквизитаРаздельно, Инд);
							
							Если ОписаниеТипов.Типы().Количество() > 1 Тогда
								ЕстьОшибки = Истина;
								Прервать;
							КонецЕсли;
							
							ОбъектМетаданных = Метаданные.НайтиПоТипу(ОписаниеТипов.Типы()[0]);
							МетаданныеРеквизита = ОбъектМетаданных.Реквизиты.Найти(Имя);
							Если МетаданныеРеквизита = Неопределено Тогда
								Для Каждого СтандартныйРеквизит Из ОбъектМетаданных.СтандартныеРеквизиты Цикл
									Если СтандартныйРеквизит.Имя = Имя Тогда
										МетаданныеРеквизита = СтандартныйРеквизит;
										Прервать;
									КонецЕсли;
								КонецЦикла;
							КонецЕсли;
							
							ОписаниеТипов = МетаданныеРеквизита.Тип;
						КонецЦикла;
						
						Если НЕ ЕстьОшибки Тогда
							Реквизит = Новый Структура("ТипЗначения", ОписаниеТипов);
						КонецЕсли;
					КонецЕсли;
					
					СтруктураСвойства.ПутьКДанным = СтрЗаменить(СтруктураСвойства.ПутьКДанным, "/", ".");
				Иначе
					Реквизит = СоответствиеРеквизиты[Имя];
				КонецЕсли;
			КонецЕсли;
			
			Если Тип(СтруктураСвойства.Тип) = Тип("ПолеФормы") Тогда
				Если Реквизит.ТипЗначения.Типы().Количество() = 1
					И Реквизит.ТипЗначения.Типы()[0] = Тип("Булево") Тогда
					
					Элемент.Вид = ВидПоляФормы.ПолеФлажка;
				Иначе
					Элемент.Вид = ВидПоляФормы.ПолеВвода;
				КонецЕсли;
				
			ИначеЕсли Тип(СтруктураСвойства.Тип) = Тип("ГруппаФормы") Тогда
				Если ИмяРодителя = Неопределено
					ИЛИ ИмяРодителя = "Форма"
					ИЛИ ТипЗнч(Форма.Элементы[ИмяРодителя]) = Тип("ГруппаФормы")
						И (Форма.Элементы[ИмяРодителя].Вид = ВидГруппыФормы.ОбычнаяГруппа
							ИЛИ Форма.Элементы[ИмяРодителя].Вид = ВидГруппыФормы.Страница) Тогда
					
					Элемент.Вид = ВидГруппыФормы.ОбычнаяГруппа;
					Элемент.Отображение = ОтображениеОбычнойГруппы.Нет;
					Элемент.ОтображатьЗаголовок = Ложь;
					
				ИначеЕсли ТипЗнч(Форма.Элементы[ИмяРодителя]) = Тип("ТаблицаФормы") Тогда
					Элемент.Вид = ВидГруппыФормы.ГруппаКолонок;
				КонецЕсли
			КонецЕсли;
			
		ИначеЕсли ИмяРодителя <> Неопределено
			И Элемент.Родитель <> Форма.Элементы[ИмяРодителя] Тогда
			
			Форма.Элементы.Переместить(Элемент, Форма.Элементы[ИмяРодителя]);
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(Элемент, СтруктураСвойства);
		
		Для Каждого ЭлементСтруктуры Из СтруктураОперации Цикл
			Если ЭлементСтруктуры.Ключ = "МестоРасположения" Тогда
				Форма.Элементы.Переместить(Элемент, Элемент.Родитель, Форма.Элементы[ЭлементСтруктуры.Значение]);
			КонецЕсли;
		КонецЦикла;
		
		Для Каждого ЭлементСтруктуры Из СтруктураДействия Цикл
			Элемент.УстановитьДействие(ЭлементСтруктуры.Ключ, ЭлементСтруктуры.Значение);
		КонецЦикла;
		
		НомСтроки = НомСтроки + 1;
		Если НомСтроки > МакетИзменений.ВысотаТаблицы Тогда
			Прервать;
		КонецЕсли;
		
		ТекстЯчейки = МакетИзменений.Область(НомСтроки, НомКолонки).Текст;
		Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
			Если НомКолонки < ШиринаИмени Тогда
				ИзменитьЭлементы(Форма, МакетИзменений, ШиринаИмени, НомСтроки, НомКолонки + 1, ИмяЭлемента);
			КонецЕсли;
			
			ТекстЯчейки = МакетИзменений.Область(НомСтроки, НомКолонки).Текст;
			Если НЕ ЗначениеЗаполнено(ТекстЯчейки) Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
		
		ИмяЭлемента = ТекстЯчейки;
	КонецЦикла;
КонецПроцедуры

Функция ВычислитьЗначениеНастройки(ИмяДействия, ТекстОписание, ТекущееЗначение = Неопределено) Экспорт
	Если ИмяДействия = "ПараметрыВыбора" Тогда
		СоответствиеПараметры = Новый Соответствие;
		Если ТекущееЗначение <> Неопределено Тогда
			Для Каждого ПараметрВыбора Из ТекущееЗначение Цикл
				СоответствиеПараметры.Вставить(ПараметрВыбора.Имя, ПараметрВыбора);	
			КонецЦикла;
		КонецЕсли;
		
		ДобавлятьТекущиеПараметры = Ложь;
		МассивПараметры = Новый Массив;
		Для Каждого Описание Из ПолучитьМассивОписаний(ТекстОписание) Цикл
			Поз = Найти(Описание, "(");
			Если Поз > 0 Тогда
				ИмяПараметра = Лев(Описание, Поз - 1);
			Иначе
				ИмяПараметра = Описание;
			КонецЕсли;
			
			Если ИмяПараметра = "*" Тогда
				ДобавлятьТекущиеПараметры = Истина;
				
			ИначеЕсли Лев(ИмяПараметра, 1) = "-" Тогда
				СоответствиеПараметры.Удалить(Сред(ИмяПараметра, 2));
			Иначе
				Если Лев(ИмяПараметра, 1) = "+" Тогда
					ИмяПараметра = Сред(ИмяПараметра, 2);
				КонецЕсли;
				
				СоответствиеПараметры.Удалить(ИмяПараметра);

				ЗначениеПараметра = Вычислить(Сред(Описание, Поз + 1, СтрДлина(Описание) - Поз - 1));
				Если ТипЗнч(ЗначениеПараметра) = Тип("Массив") Тогда
					ЗначениеПараметра = Новый ФиксированныйМассив(ЗначениеПараметра);
				КонецЕсли;
				
				МассивПараметры.Добавить(Новый ПараметрВыбора(ИмяПараметра, ЗначениеПараметра));
			КонецЕсли;
		КонецЦикла;
		
		Если ДобавлятьТекущиеПараметры Тогда
			Инд = 0;
			Для Каждого ЭлементСоответствия Из СоответствиеПараметры Цикл
				МассивПараметры.Вставить(Инд, ЭлементСоответствия.Значение);
				Инд = Инд + 1;
			КонецЦикла;
		КонецЕсли;
		
		Возврат Новый ФиксированныйМассив(МассивПараметры);
		
	ИначеЕсли ИмяДействия = "СвязиПараметровВыбора" Тогда
		СоответствиеСвязи = Новый Соответствие;
		Если ТекущееЗначение <> Неопределено Тогда
			Для Каждого СвязьПараметров Из ТекущееЗначение Цикл
				СоответствиеСвязи.Вставить(СвязьПараметров.Имя, СвязьПараметров);	
			КонецЦикла;
		КонецЕсли;
		
		ДобавлятьТекущиеСвязи = Ложь;
		МассивСвязи = Новый Массив;
		Для Каждого Описание Из ПолучитьМассивОписаний(ТекстОписание) Цикл
			Поз = Найти(Описание, "(");
			Если Поз > 0 Тогда
				ИмяПараметра = Лев(Описание, Поз - 1);
			Иначе
				ИмяПараметра = Описание;
			КонецЕсли;
			
			Если ИмяПараметра = "*" Тогда
				ДобавлятьТекущиеСвязи = Истина;
			
			ИначеЕсли Лев(ИмяПараметра, 1) = "-" Тогда
				СоответствиеСвязи.Удалить(Сред(ИмяПараметра, 2));
			Иначе
				Если Лев(ИмяПараметра, 1) = "+" Тогда
					ИмяПараметра = Сред(ИмяПараметра, 2);
				КонецЕсли;
				СоответствиеСвязи.Удалить(ИмяПараметра);
				
				ЗначениеСвязи = Сред(Описание, Поз + 1, СтрДлина(Описание) - Поз - 1);
				МассивСвязи.Добавить(Новый СвязьПараметраВыбора(ИмяПараметра, ЗначениеСвязи));
			КонецЕсли;
		КонецЦикла;
		
		Если ДобавлятьТекущиеСвязи Тогда
			Инд = 0;
			Для Каждого ЭлементСоответствия Из СоответствиеСвязи Цикл
				МассивСвязи.Вставить(Инд, ЭлементСоответствия.Значение);
				Инд = Инд + 1;
			КонецЦикла;
		КонецЕсли;
		
		Возврат Новый ФиксированныйМассив(МассивСвязи);
		
	ИначеЕсли ИмяДействия = "ОписаниеТипов" Тогда
		МассивТипы = Новый Массив;
		КвалификаторыЧисла = Неопределено;
		КвалификаторыДаты = Неопределено;
		КвалификаторыСтроки = Неопределено;
		
		Для Каждого Описание Из ПолучитьМассивОписаний(ТекстОписание) Цикл
			Поз = Найти(Описание, "(");
			Если Поз > 0 Тогда
				ИмяТипа = Лев(Описание, Поз - 1);
				МассивПараметры = СтрРазделить(Сред(Описание, Поз + 1, СтрДлина(Описание) - Поз - 1), ",");
				МассивОписаниеПараметров = Новый Массив;
				Если ИмяТипа = "Число" Тогда
					МассивОписаниеПараметров.Добавить("Число(%1)");
					МассивОписаниеПараметров.Добавить("Число(%1)");
					МассивОписаниеПараметров.Добавить("ДопустимыйЗнак[%1]");
					
					КвалификаторыЧисла = Вычислить("Новый КвалификаторыЧисла(" + ПолучитьТекстПараметров(МассивПараметры, МассивОписаниеПараметров) + ")");
					
				ИначеЕсли ИмяТипа = "Строка" Тогда
					МассивОписаниеПараметров.Добавить("Число(%1)");
					МассивОписаниеПараметров.Добавить("ДопустимаяДлина[%1]");
					
					КвалификаторыСтроки = Вычислить("Новый КвалификаторыСтроки(" + ПолучитьТекстПараметров(МассивПараметры, МассивОписаниеПараметров) + ")");
					
				ИначеЕсли ИмяТипа = "Дата" Тогда
					МассивОписаниеПараметров.Добавить("ЧастиДаты[%1]");
					
					КвалификаторыДаты = Вычислить("Новый КвалификаторыДаты(" + ПолучитьТекстПараметров(МассивПараметры, МассивОписаниеПараметров) + ")");
				КонецЕсли;
			Иначе
				ИмяТипа = Описание;
			КонецЕсли;
			
			МассивТипы.Добавить(Тип(ИмяТипа));
		КонецЦикла;
		
		Возврат Новый ОписаниеТипов(МассивТипы, , , КвалификаторыЧисла, КвалификаторыСтроки, КвалификаторыДаты);
	Иначе
		Возврат Вычислить(ИмяДействия + "." + ТекстОписание);
	КонецЕсли;
КонецФункции

Функция ПолучитьТекстПараметров(МассивПараметры, МассивОписаниеПараметров)
	ТекстРезультат = "";
	Для Инд = 1 По МассивПараметры.Количество() Цикл
		Если НЕ ПустаяСтрока(МассивПараметры[Инд - 1]) Тогда
			ТекстРезультат = ТекстРезультат + "," + СтрЗаменить(МассивОписаниеПараметров[Инд - 1], "%1", "МассивПараметры[" + Число(Инд - 1) + "]");
		Иначе
			ТекстРезультат = ТекстРезультат + ",";
		КонецЕсли;
	КонецЦикла;
	
	Возврат Сред(ТекстРезультат, 2);
КонецФункции

Функция ПолучитьМассивОписаний(ТекстОписание)
	МассивРезультат = Новый Массив;
	
	НачалоОписания = 1;
	СчетчикСкобок = 0;
	РежимСтроки = Ложь;
	Для Инд = 1 По СтрДлина(ТекстОписание) Цикл
		ТекущийСимвол = Сред(ТекстОписание, Инд, 1);
		Если ТекущийСимвол = ","
			И НЕ РежимСтроки
			И СчетчикСкобок = 0 Тогда
			
			Описание = СокрЛП(Сред(ТекстОписание, НачалоОписания, Инд - НачалоОписания));
			Если ЗначениеЗаполнено(Описание) Тогда
				МассивРезультат.Добавить(СокрЛП(Описание));
			КонецЕсли;
			
			НачалоОписания = Инд + 1;
			
		ИначеЕсли ТекущийСимвол = """" Тогда
			РежимСтроки = НЕ РежимСтроки;
			
		ИначеЕсли НЕ РежимСтроки
			И ТекущийСимвол = "(" Тогда
			
			СчетчикСкобок = СчетчикСкобок + 1;
			
		ИначеЕсли НЕ РежимСтроки
			И ТекущийСимвол = ")" Тогда
			
			СчетчикСкобок = СчетчикСкобок - 1;
		КонецЕсли;
	КонецЦикла;
	
	Если РежимСтроки Тогда
		ВызватьИсключение "Не найдена завершающая "" в " + ТекстОписание;
	ИначеЕсли СчетчикСкобок > 0 Тогда
		ВызватьИсключение "Не найдена завершающая ) в " + ТекстОписание;
	КонецЕсли;
	
	Описание = СокрЛП(Сред(ТекстОписание, НачалоОписания, Инд - НачалоОписания));
	Если ЗначениеЗаполнено(Описание) Тогда
		МассивРезультат.Добавить(СокрЛП(Описание));
	КонецЕсли;
	
	Возврат МассивРезультат;
КонецФункции