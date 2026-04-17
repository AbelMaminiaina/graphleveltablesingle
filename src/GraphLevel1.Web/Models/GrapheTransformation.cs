namespace GraphLevel1.Web.Models;

/// <summary>
/// Table contenant les transformations avec leurs inputs et outputs
/// </summary>
public class GrapheTransformation
{
    public int Id { get; set; }

    public int IdType { get; set; }

    // Inputs
    public string? Input1 { get; set; }
    public string? Input2 { get; set; }
    public string? Input3 { get; set; }
    public string? Input4 { get; set; }

    // Transformation
    public string Transformation { get; set; } = string.Empty;

    // Outputs
    public string? Output1 { get; set; }
    public string? Output2 { get; set; }
    public string? Output3 { get; set; }
    public string? Output4 { get; set; }

    // Metadata
    public string? Proprietaire { get; set; }
    public DateTime DateCreation { get; set; }
}
