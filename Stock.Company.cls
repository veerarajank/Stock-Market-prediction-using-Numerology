Class Stock.Company Extends %Persistent
{

Property CompanyName As %String(MAXLEN = "");

Index IdxOnCompany On CompanyName;

ClassMethod InsertCompany(Company As %String) As %Integer
{
	Set Id=$O(^Stock.CompanyI("IdxOnCompany"," "_Company))
	If Id>0 Quit Id
	Set obj=..%New()
	Set obj.CompanyName=Company
	Do obj.%Save()
	Quit obj.%Id()
}

Storage Default
{
<Data name="CompanyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CompanyName</Value>
</Value>
</Data>
<DataLocation>^Stock.CompanyD</DataLocation>
<DefaultData>CompanyDefaultData</DefaultData>
<IdLocation>^Stock.CompanyD</IdLocation>
<IndexLocation>^Stock.CompanyI</IndexLocation>
<StreamLocation>^Stock.CompanyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
