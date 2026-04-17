using Microsoft.EntityFrameworkCore;
using GraphLevel1.Web.Data;
using GraphLevel1.Web.Models;

namespace GraphLevel1.Web.Services;

public interface IGraphService
{
    Task<List<TransformationSearchResult>> SearchByInputsAsync(string? input1, string? input2, string? input3, string? input4);
    Task<GraphViewModel?> GetTransformationDetailsAsync(string transformation);
    Task<List<LineageItem>> GetSuccessorsAsync(string transformation);
    Task<List<LineageItem>> GetPredecessorsAsync(string transformation);
}

public class GraphService : IGraphService
{
    private readonly GraphDbContext _context;

    public GraphService(GraphDbContext context)
    {
        _context = context;
    }

    public async Task<List<TransformationSearchResult>> SearchByInputsAsync(string? input1, string? input2, string? input3, string? input4)
    {
        var inputs = new List<string>();
        if (!string.IsNullOrWhiteSpace(input1)) inputs.Add(input1.Trim());
        if (!string.IsNullOrWhiteSpace(input2)) inputs.Add(input2.Trim());
        if (!string.IsNullOrWhiteSpace(input3)) inputs.Add(input3.Trim());
        if (!string.IsNullOrWhiteSpace(input4)) inputs.Add(input4.Trim());

        if (inputs.Count == 0)
            return new List<TransformationSearchResult>();

        // Recherche les transformations qui ont des inputs/outputs correspondants
        var query = _context.GrapheTransformations.AsQueryable();

        // Construire la requete pour chercher dans tous les champs input/output
        var matchingTransformations = await query
            .Where(g =>
                inputs.Any(i =>
                    (g.Input1 != null && g.Input1.Contains(i)) ||
                    (g.Input2 != null && g.Input2.Contains(i)) ||
                    (g.Input3 != null && g.Input3.Contains(i)) ||
                    (g.Input4 != null && g.Input4.Contains(i)) ||
                    (g.Output1 != null && g.Output1.Contains(i)) ||
                    (g.Output2 != null && g.Output2.Contains(i)) ||
                    (g.Output3 != null && g.Output3.Contains(i)) ||
                    (g.Output4 != null && g.Output4.Contains(i)) ||
                    g.Transformation.Contains(i)
                ))
            .ToListAsync();

        var results = new List<TransformationSearchResult>();
        foreach (var transfo in matchingTransformations)
        {
            var outputs = GetNonNullValues(transfo.Output1, transfo.Output2, transfo.Output3, transfo.Output4);
            var transfoInputs = GetNonNullValues(transfo.Input1, transfo.Input2, transfo.Input3, transfo.Input4);

            // Compter les successeurs (transformations qui utilisent nos outputs comme inputs)
            var successorCount = outputs.Count > 0
                ? await _context.GrapheTransformations.CountAsync(g =>
                    g.Transformation != transfo.Transformation &&
                    ((g.Input1 != null && outputs.Contains(g.Input1)) ||
                     (g.Input2 != null && outputs.Contains(g.Input2)) ||
                     (g.Input3 != null && outputs.Contains(g.Input3)) ||
                     (g.Input4 != null && outputs.Contains(g.Input4))))
                : 0;

            // Compter les predecesseurs (transformations dont les outputs sont nos inputs)
            var predecessorCount = transfoInputs.Count > 0
                ? await _context.GrapheTransformations.CountAsync(g =>
                    g.Transformation != transfo.Transformation &&
                    ((g.Output1 != null && transfoInputs.Contains(g.Output1)) ||
                     (g.Output2 != null && transfoInputs.Contains(g.Output2)) ||
                     (g.Output3 != null && transfoInputs.Contains(g.Output3)) ||
                     (g.Output4 != null && transfoInputs.Contains(g.Output4))))
                : 0;

            results.Add(new TransformationSearchResult
            {
                Transformation = transfo.Transformation,
                Proprietaire = transfo.Proprietaire,
                IdType = transfo.IdType,
                SuccessorCount = successorCount,
                PredecessorCount = predecessorCount
            });
        }

        return results.OrderBy(r => r.Transformation).Take(100).ToList();
    }

    public async Task<GraphViewModel?> GetTransformationDetailsAsync(string transformation)
    {
        var transfo = await _context.GrapheTransformations
            .FirstOrDefaultAsync(g => g.Transformation == transformation);

        if (transfo == null)
            return null;

        return new GraphViewModel
        {
            Transformation = transfo.Transformation,
            Proprietaire = transfo.Proprietaire,
            IdType = transfo.IdType,
            Input1 = transfo.Input1,
            Input2 = transfo.Input2,
            Input3 = transfo.Input3,
            Input4 = transfo.Input4,
            Output1 = transfo.Output1,
            Output2 = transfo.Output2,
            Output3 = transfo.Output3,
            Output4 = transfo.Output4,
            Successors = await GetSuccessorsAsync(transformation),
            Predecessors = await GetPredecessorsAsync(transformation)
        };
    }

    // NIVEAU 1 SEULEMENT - Successeurs directs
    // Les successeurs sont les transformations dont les inputs correspondent a nos outputs
    public async Task<List<LineageItem>> GetSuccessorsAsync(string transformation)
    {
        var current = await _context.GrapheTransformations
            .FirstOrDefaultAsync(g => g.Transformation == transformation);

        if (current == null)
            return new List<LineageItem>();

        var outputs = GetNonNullValues(current.Output1, current.Output2, current.Output3, current.Output4);

        if (outputs.Count == 0)
            return new List<LineageItem>();

        var successors = await _context.GrapheTransformations
            .Where(g => g.Transformation != transformation &&
                ((g.Input1 != null && outputs.Contains(g.Input1)) ||
                 (g.Input2 != null && outputs.Contains(g.Input2)) ||
                 (g.Input3 != null && outputs.Contains(g.Input3)) ||
                 (g.Input4 != null && outputs.Contains(g.Input4))))
            .ToListAsync();

        var results = new List<LineageItem>();
        foreach (var succ in successors)
        {
            var succInputs = GetNonNullValues(succ.Input1, succ.Input2, succ.Input3, succ.Input4);
            var linkingData = outputs.Intersect(succInputs).FirstOrDefault() ?? "";

            results.Add(new LineageItem
            {
                Transformation = succ.Transformation,
                IdType = succ.IdType,
                Proprietaire = succ.Proprietaire,
                LinkingData = linkingData,
                Path = transformation + " -> " + succ.Transformation
            });
        }

        return results.OrderBy(x => x.Transformation).ToList();
    }

    // NIVEAU 1 SEULEMENT - Predecesseurs directs
    // Les predecesseurs sont les transformations dont les outputs correspondent a nos inputs
    public async Task<List<LineageItem>> GetPredecessorsAsync(string transformation)
    {
        var current = await _context.GrapheTransformations
            .FirstOrDefaultAsync(g => g.Transformation == transformation);

        if (current == null)
            return new List<LineageItem>();

        var inputs = GetNonNullValues(current.Input1, current.Input2, current.Input3, current.Input4);

        if (inputs.Count == 0)
            return new List<LineageItem>();

        var predecessors = await _context.GrapheTransformations
            .Where(g => g.Transformation != transformation &&
                ((g.Output1 != null && inputs.Contains(g.Output1)) ||
                 (g.Output2 != null && inputs.Contains(g.Output2)) ||
                 (g.Output3 != null && inputs.Contains(g.Output3)) ||
                 (g.Output4 != null && inputs.Contains(g.Output4))))
            .ToListAsync();

        var results = new List<LineageItem>();
        foreach (var pred in predecessors)
        {
            var predOutputs = GetNonNullValues(pred.Output1, pred.Output2, pred.Output3, pred.Output4);
            var linkingData = inputs.Intersect(predOutputs).FirstOrDefault() ?? "";

            results.Add(new LineageItem
            {
                Transformation = pred.Transformation,
                IdType = pred.IdType,
                Proprietaire = pred.Proprietaire,
                LinkingData = linkingData,
                Path = pred.Transformation + " -> " + transformation
            });
        }

        return results.OrderBy(x => x.Transformation).ToList();
    }

    private static List<string> GetNonNullValues(params string?[] values)
    {
        return values.Where(v => !string.IsNullOrWhiteSpace(v)).Select(v => v!).ToList();
    }
}
