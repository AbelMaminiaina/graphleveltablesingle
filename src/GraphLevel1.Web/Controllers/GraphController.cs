using Microsoft.AspNetCore.Mvc;
using GraphLevel1.Web.Services;

namespace GraphLevel1.Web.Controllers;

public class GraphController : Controller
{
    private readonly IGraphService _graphService;

    public GraphController(IGraphService graphService)
    {
        _graphService = graphService;
    }

    // GET: /Graph/Details?transformation=XXX - Ecran 2: Successeurs et Predecesseurs (Niveau 1)
    public async Task<IActionResult> Details(string transformation)
    {
        if (string.IsNullOrWhiteSpace(transformation))
        {
            return NotFound();
        }

        var model = await _graphService.GetTransformationDetailsAsync(transformation);
        if (model == null)
        {
            return NotFound();
        }

        return View(model);
    }

    // GET: /Graph/Successors?transformation=XXX - API pour AJAX (Niveau 1)
    [HttpGet]
    public async Task<IActionResult> Successors(string transformation)
    {
        var successors = await _graphService.GetSuccessorsAsync(transformation);
        return Json(successors);
    }

    // GET: /Graph/Predecessors?transformation=XXX - API pour AJAX (Niveau 1)
    [HttpGet]
    public async Task<IActionResult> Predecessors(string transformation)
    {
        var predecessors = await _graphService.GetPredecessorsAsync(transformation);
        return Json(predecessors);
    }
}
