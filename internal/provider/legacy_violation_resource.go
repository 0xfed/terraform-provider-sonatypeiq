package provider

import (
	"context"
	"fmt"
	"strings"

	sonatypeiq "github.com/0xfed/nexus-iq-api-client-go"
	"github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/schema/validator"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

// var _ resource.ResourceWithImportState = &legacyViolationResource{}

type legacyViolationResource struct {
	baseResource
}

type legacyViolationModelResource struct {
	ID            types.String `tfsdk:"owner_id"`
	OwnerType     types.String `tfsdk:"owner_type"`
	AllowOverride types.String `tfsdk:"allow_override"`
	Enabled       types.String `tfsdk:"enabled"`
}

func NewLegacyViolationResource() resource.Resource {
	return &legacyViolationResource{}
}

func (r *legacyViolationResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_legacy_violation"
}

func (r *legacyViolationResource) Schema(_ context.Context, req resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"owner_id": schema.StringAttribute{
				Required:            true,
				MarkdownDescription: "The ID of the owner of the violation.",
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"owner_type": schema.StringAttribute{
				Required:            true,
				MarkdownDescription: "The type of the owner, must be one of 'organization' or 'application'.",
				Validators: []validator.String{
					stringvalidator.OneOf("organization", "application"),
				},
			},
			"allow_override": schema.StringAttribute{
				Required:            true,
				MarkdownDescription: "Controls whether the policy can be overridden at application level",
				// Validators: []validator.String{
				// 	stringvalidator.OneOf("null", "true", "false"),
				// },
			},
			"enabled": schema.StringAttribute{
				Required:            true,
				MarkdownDescription: "Enable is null then it's inherit.",
				// Validators: []validator.String{
				// 	stringvalidator.OneOf("null", "true", "false"),
				// },
			},
		},
	}
}

func (r *legacyViolationResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var plan legacyViolationModelResource
	diags := req.Plan.Get(ctx, &plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	ctx = context.WithValue(
		ctx,
		sonatypeiq.ContextBasicAuth,
		r.auth,
	)

	// create the resource
	legacyViolationRequest := r.client.LegacyViolationsAPI.RestLegacyViolationsOwnerTypeOrganizationIdPut(ctx, strings.Trim(plan.ID.String(), "\""), strings.Trim(plan.OwnerType.String(), "\"")).LegacyViolationsDTO(sonatypeiq.LegacyViolationsDTO{
		AllowOverride: plan.AllowOverride.ValueString(),
		Enabled:       plan.Enabled.ValueString(),
	})

	legacyViolationResponse, _, err := legacyViolationRequest.Execute()

	if err != nil {
		resp.Diagnostics.AddError("ERROR create legacy violation", err.Error())
		return
	}
	plan.AllowOverride = types.StringValue(fmt.Sprintf("%v", types.BoolPointerValue(legacyViolationResponse.AllowOverride)))
	replacer := strings.NewReplacer("<", "", ">", "")
	plan.Enabled = types.StringValue(replacer.Replace(fmt.Sprintf("%v", types.BoolPointerValue(legacyViolationResponse.Enabled))))

	// plan.ID = types.StringValue(*legacyviolation.ID)
	diags = resp.State.Set(ctx, plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

func (r *legacyViolationResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state legacyViolationModelResource
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	ctx = context.WithValue(
		ctx,
		sonatypeiq.ContextBasicAuth,
		r.auth,
	)

	// read the resource
	legacyViolationResponse, _, err := r.client.LegacyViolationsAPI.RestLegacyViolationsOwnerTypeOrganizationIdGet(ctx, strings.Trim(state.ID.String(), "\""), strings.Trim(state.OwnerType.String(), "\"")).Execute()

	if err != nil {
		resp.Diagnostics.AddError("ERROR reading legacy violation", err.Error())
		return
	}

	state.AllowOverride = types.StringValue(fmt.Sprintf("%v", types.BoolPointerValue(legacyViolationResponse.AllowOverride)))
	replacer := strings.NewReplacer("<", "", ">", "")
	state.Enabled = types.StringValue(replacer.Replace(fmt.Sprintf("%v", types.BoolPointerValue(legacyViolationResponse.Enabled))))

	diags = resp.State.Set(ctx, state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

func (r *legacyViolationResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var plan legacyViolationModelResource
	diags := req.Plan.Get(ctx, &plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var state legacyViolationModelResource
	diags = req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	ctx = context.WithValue(
		ctx,
		sonatypeiq.ContextBasicAuth,
		r.auth,
	)

	// update the resource
	legacyViolationRequest := r.client.LegacyViolationsAPI.RestLegacyViolationsOwnerTypeOrganizationIdPut(ctx, strings.Trim(plan.ID.String(), "\""), strings.Trim(plan.OwnerType.String(), "\"")).LegacyViolationsDTO(sonatypeiq.LegacyViolationsDTO{
		AllowOverride: plan.AllowOverride.ValueString(),
		Enabled:       plan.Enabled.ValueString(),
	})

	legacyViolationResponse, _, err := legacyViolationRequest.Execute()

	if err != nil {
		resp.Diagnostics.AddError("ERROR updating legacy violation", err.Error())
		return
	}

	plan.AllowOverride = types.StringValue(fmt.Sprintf("%v", types.BoolPointerValue(legacyViolationResponse.AllowOverride)))
	replacer := strings.NewReplacer("<", "", ">", "")
	plan.Enabled = types.StringValue(replacer.Replace(fmt.Sprintf("%v", types.BoolPointerValue(legacyViolationResponse.Enabled))))

	diags = resp.State.Set(ctx, plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}
func (r *legacyViolationResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {

}

func (r *legacyViolationResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	if req.ProviderData == nil {
		return
	}

	config, ok := req.ProviderData.(SonatypeDataSourceData)
	if !ok {
		resp.Diagnostics.AddError(
			"Unexpected Data Source Type",
			fmt.Sprintf("Expected provider.SonatypeDataSourceData, got: %T. Please report this issue to the provider developers.", req.ProviderData),
		)
		return
	}

	r.client = config.client
	r.client.GetConfig().DefaultHeader = map[string]string{
		"X-CSRF-TOKEN": "api",
		"Cookie":       "CLM-CSRF-TOKEN=api;",
	}
	r.auth = config.auth
}
