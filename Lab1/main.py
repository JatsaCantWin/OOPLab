from requests import get
import xml.etree.cElementTree


class Currency:
    def __init__(self, name, multiplier, tag, value):
        self.name = name
        self.multiplier = multiplier
        self.tag = tag
        self.value = value


class XMLDownloader:
    @staticmethod
    def downloadXML():
        return get('https://www.nbp.pl/kursy/xml/lasta.xml')


class XMLParser:
    @staticmethod
    def parseXML(xmlFile):
        result = list()
        for currentCurrency in xml.etree.cElementTree.fromstring(xmlFile.text).findall('pozycja'):
            for currentChild in list(currentCurrency):
                match currentChild.tag:
                    case 'nazwa_waluty':
                        currentCurrencyName = currentChild.text
                    case 'przelicznik':
                        currentCurrencyMultiplier = float(currentChild.text.replace(',', '.'))
                    case 'kod_waluty':
                        currentCurrencyTag = currentChild.text
                    case 'kurs_sredni':
                        currentCurrencyValue = float(currentChild.text.replace(',', '.'))
                    case _:
                        print("Blad w parsowaniu walut")
                        quit()
            result.append(
                Currency(currentCurrencyName, currentCurrencyMultiplier, currentCurrencyTag, currentCurrencyValue))
        return result


class CurrencyDatabase:
    def __init__(self):
        self.downloadCurrencies()

    def getCurrency(self, tag):
        for currentCurrency in self.currencies:
            if currentCurrency.tag == tag:
                return currentCurrency
        return False

    def downloadCurrencies(self):
        self.currencies = XMLParser.parseXML(XMLDownloader.downloadXML())
        self.currencies.append(Currency('polski zloty', 1.0, 'PLN', 1.0))

    def compareCurrencies(self, firstCurrency, secondCurrency):
        return (firstCurrency.value / firstCurrency.multiplier) / (secondCurrency.value / secondCurrency.multiplier)


class CurrencyCalculator:

    def calculateSecondCurrencyPrice(self):
        self.secondCurrencyAmount = self.firstCurrencyAmount * currencyDatabase.compareCurrencies(
            currencyDatabase.getCurrency(self.firstCurrencyTag), currencyDatabase.getCurrency(self.secondCurrencyTag))

    def setFirstCurrencyTag(self, tag):
        if currencyDatabase.getCurrency(tag):
            self.firstCurrencyTag = tag
            return True
        return False

    def setFirstCurrencyAmount(self, amount):
        try:
            amount = float(amount)
            self.firstCurrencyAmount = amount
            return True
        except ValueError:
            return False

    def setSecondCurrencyTag(self, tag):
        if currencyDatabase.getCurrency(tag):
            self.secondCurrencyTag = tag
            self.calculateSecondCurrencyPrice()
            return True
        return False

    def getFirstCurrencyTag(self):
        return self.firstCurrencyTag

    def getFirstCurrencyAmount(self):
        return self.firstCurrencyAmount

    def getSecondCurrencyTag(self):
        return self.secondCurrencyTag

    def getSecondCurrencyAmount(self):
        return self.secondCurrencyAmount


class UserInterface:
    @staticmethod
    def getUserInptut():
        print("Podaj kod waluty wejsciowej:")
        while not (currencyCalculator.setFirstCurrencyTag(input())):
            print("Niepoprawny kod waluty wejsciowej")
        print("Podaj ilosc waluty wejsciowej:")
        while not (currencyCalculator.setFirstCurrencyAmount(input())):
            print("Niepoprawna wartosc waluty wejsciowej")
        print("Podaj kod waluty wyjsciowej:")
        while not (currencyCalculator.setSecondCurrencyTag(input())):
            print("Niepoprawny kod waluty wejsciowej")

    @staticmethod
    def printOutput():
        print("Wartosc waluty wyjsciowej:")
        print(currencyCalculator.getSecondCurrencyAmount())


currencyCalculator = CurrencyCalculator()
currencyDatabase = CurrencyDatabase()

while True:
    UserInterface.getUserInptut()
    UserInterface.printOutput()
