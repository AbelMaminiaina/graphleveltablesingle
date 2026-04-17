using Microsoft.EntityFrameworkCore;
using GraphLevel1.Web.Data;
using GraphLevel1.Web.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllersWithViews();

// Database
builder.Services.AddDbContext<GraphDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("GraphDb")));

// Services
builder.Services.AddScoped<IGraphService, GraphService>();

var app = builder.Build();

// Configure pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
