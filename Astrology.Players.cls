Class Astrology.Players Extends %Persistent
{

Property Name As %String(MAXLEN = "");

Property DOB As %String;

Property FateNumber As %Integer;

Property Team As %String;

Property DOBStr As %Integer [ Calculated, SqlComputeCode = {Set {*}=$P({DOB},"-",3)}, SqlComputed ];

Index IdxPlayer On (Name, DOB);

Index IdxPlayerName On Name;

ClassMethod InsertPlayer(Name, DOB, Team) As %Integer
{
	Set obj=..%New()
	Set obj.Name=Name
	Set obj.DOB=DOB
	Set obj.Team=Team
	Set obj.FateNumber=##class(Astrology.History).FateNumber(DOB)
	Do obj.%Save()
	Quit obj.%Id()
}

Storage Default
{
<Data name="PlayersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>DOB</Value>
</Value>
<Value name="4">
<Value>FateNumber</Value>
</Value>
<Value name="5">
<Value>Team</Value>
</Value>
</Data>
<DataLocation>^Astrology.PlayersD</DataLocation>
<DefaultData>PlayersDefaultData</DefaultData>
<IdLocation>^Astrology.PlayersD</IdLocation>
<IndexLocation>^Astrology.PlayersI</IndexLocation>
<StreamLocation>^Astrology.PlayersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
