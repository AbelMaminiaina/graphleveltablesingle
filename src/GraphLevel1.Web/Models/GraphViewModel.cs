namespace GraphLevel1.Web.Models;

public class GraphViewModel
{
    public string Transformation { get; set; } = string.Empty;
    public string? Proprietaire { get; set; }
    public int IdType { get; set; }

    // Inputs et Outputs de la transformation
    public string? Input1 { get; set; }
    public string? Input2 { get; set; }
    public string? Input3 { get; set; }
    public string? Input4 { get; set; }
    public string? Output1 { get; set; }
    public string? Output2 { get; set; }
    public string? Output3 { get; set; }
    public string? Output4 { get; set; }

    public List<LineageItem> Successors { get; set; } = new();
    public List<LineageItem> Predecessors { get; set; } = new();
}

public class LineageItem
{
    public string Transformation { get; set; } = string.Empty;
    public int IdType { get; set; }
    public string? Proprietaire { get; set; }
    public string LinkingData { get; set; } = string.Empty; // La donnee qui fait le lien
    public string Path { get; set; } = string.Empty;
}
