using Microsoft.EntityFrameworkCore;
using GraphLevel1.Web.Models;

namespace GraphLevel1.Web.Data;

public class GraphDbContext : DbContext
{
    public GraphDbContext(DbContextOptions<GraphDbContext> options) : base(options)
    {
    }

    public DbSet<GrapheTransformation> GrapheTransformations => Set<GrapheTransformation>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<GrapheTransformation>(entity =>
        {
            entity.ToTable("GrapheTransformation");
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.IdType).HasColumnName("id_type");

            // Inputs
            entity.Property(e => e.Input1).HasColumnName("input1");
            entity.Property(e => e.Input2).HasColumnName("input2");
            entity.Property(e => e.Input3).HasColumnName("input3");
            entity.Property(e => e.Input4).HasColumnName("input4");

            // Transformation
            entity.Property(e => e.Transformation)
                .HasColumnName("transformation")
                .IsRequired();

            // Outputs
            entity.Property(e => e.Output1).HasColumnName("output1");
            entity.Property(e => e.Output2).HasColumnName("output2");
            entity.Property(e => e.Output3).HasColumnName("output3");
            entity.Property(e => e.Output4).HasColumnName("output4");

            // Metadata
            entity.Property(e => e.Proprietaire).HasColumnName("proprietaire");
            entity.Property(e => e.DateCreation).HasColumnName("date_creation");

            // Index pour optimiser les recherches
            entity.HasIndex(e => e.Transformation);
        });
    }
}
