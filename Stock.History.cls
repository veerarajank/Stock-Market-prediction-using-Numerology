Class Stock.History Extends %Persistent
{

Property CompanyName As Stock.Company;

Property HistoryDate As %String;

Property FateNumber As %Integer;

Property Open As %Float;

Property Close As %Float;

Property Diff As %Float;

Property Signal As %Integer;

Index IdxHistory On (CompanyName, HistoryDate);

ClassMethod LoadFile(Company As %Integer)
{
	Set obj=##class(%FileCharacterStream).%New()
	Set obj.Filename="C:\temp\upload\Quote-Equity-INFY-EQ-17-04-2019-to-17-04-2021.csv"
	While('obj.AtEnd)
	{
		Set txt=obj.ReadLine()
		If $TR($P(txt,",",1),"""","")="Date " Continue
		Set HDate=$zd($zdh($TR($P(txt,",",1),""","""),5),3)
		Set Id=$O(^Stock.HistoryI("IdxHistory",Company," "_HDate,""))
		If Id>0
		{
			Set stock=..%OpenId(Id)
		}
		Else
		{
			Set stock=..%New()
			Set stock.HistoryDate=HDate
		}
		Set TRDate=$TR(HDate,"-")
		Set stock.CompanyName=##class(Stock.Company).%OpenId(Company)
		Set stock.FateNumber=..SingleDigit(TRDate)
		Set stock.Open=$TR($P(txt,""",""",3),"""","")
		Set stock.Close=$TR($P(txt,""",""",8),"""","")
		Set stock.Diff=stock.Close-stock.Open
		If stock.Diff=0
		{
			Set stock.Signal=3
		}
		ElseIf stock.Diff>0
		{
			Set stock.Signal=1
		}
		ElseIf stock.Diff<0
		{
			Set stock.Signal=2
		}
		Do stock.%Save()
		
	}
	Do obj.%Close()
}

ClassMethod SingleDigit(TRDate As %Integer) As %Integer
{
	Set Total=0
	For 
	{
		For inc=1:1:$L(TRDate)
		{
			Set Total=Total+$E(TRDate,inc)
		}
		Quit:$L(Total)=1
		Set TRDate=Total,Total=0
	}
	Quit Total
}

Storage Default
{
<Data name="HistoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CompanyName</Value>
</Value>
<Value name="3">
<Value>HistoryDate</Value>
</Value>
<Value name="4">
<Value>Open</Value>
</Value>
<Value name="5">
<Value>Close</Value>
</Value>
<Value name="6">
<Value>Diff</Value>
</Value>
<Value name="7">
<Value>Signal</Value>
</Value>
<Value name="8">
<Value>FateNumber</Value>
</Value>
</Data>
<DataLocation>^Stock.HistoryD</DataLocation>
<DefaultData>HistoryDefaultData</DefaultData>
<IdLocation>^Stock.HistoryD</IdLocation>
<IndexLocation>^Stock.HistoryI</IndexLocation>
<StreamLocation>^Stock.HistoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
