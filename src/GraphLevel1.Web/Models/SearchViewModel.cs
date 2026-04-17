namespace GraphLevel1.Web.Models;

public class SearchViewModel
{
    public string? Input1 { get; set; }
    public string? Input2 { get; set; }
    public string? Input3 { get; set; }
    public string? Input4 { get; set; }
    public List<TransformationSearchResult> Results { get; set; } = new();
    public bool HasSearched { get; set; }
}

public class TransformationSearchResult
{
    public string Transformation { get; set; } = string.Empty;
    public string? Proprietaire { get; set; }
    public int IdType { get; set; }
    public int SuccessorCount { get; set; }
    public int PredecessorCount { get; set; }
}
