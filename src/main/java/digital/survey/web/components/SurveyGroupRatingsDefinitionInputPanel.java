/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.components;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.*;
import guru.mmp.application.web.template.components.ExtensibleFormDialogImplementation;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

/**
 * The <code>SurveyGroupRatingsDefinitionInputPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyGroupRatingsDefinitionInputPanel extends SurveyItemDefinitionInputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinitionInputPanel</code>.
   *
   * @param id                          the non-null id of this component
   * @param groupRatingsDefinitionModel the model for the survey group ratings definition
   * @param groupDefinitionModel        the model for the survey group definition
   */
  public SurveyGroupRatingsDefinitionInputPanel(String id,
      IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel,
      IModel<SurveyGroupDefinition> groupDefinitionModel)
  {
    super(id, groupRatingsDefinitionModel);

    add(new ListView<SurveyGroupRatingDefinition>("groupRatingDefinition", new PropertyModel<>(
        groupRatingsDefinitionModel, "groupRatingDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            item.add(new Label("name", new PropertyModel(item.getModel(), "name")));

            // The "moveLeftLink" link
            AjaxLink moveLeftLink = new AjaxLink("moveLeftLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                SurveyDefinition surveyDefinition =
                    (SurveyDefinition) getForm().getDefaultModelObject();

                surveyDefinition.moveGroupRatingDefinitionUp(item.getModelObject());

                target.add(SurveyGroupRatingsDefinitionInputPanel.this);
              }
            };

            if (item.getIndex() == 0)
            {
              moveLeftLink.setVisible(false);
            }

            item.add(moveLeftLink);

            // The "removeLink" link
            item.add(new AjaxLink("removeLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                getDialog().show(target, new RemoveGroupRatingDialogImplementation(item.getModel()));
              }
            });

            // The "moveRightLink" link
            AjaxLink moveRightLink = new AjaxLink("moveRightLink")

            {
              @Override
              public void onClick(AjaxRequestTarget ajaxRequestTarget)
              {
                SurveyDefinition surveyDefinition =
                    (SurveyDefinition) getForm().getDefaultModelObject();

                surveyDefinition.moveGroupRatingDefinitionDown(item.getModelObject());

                ajaxRequestTarget.add(SurveyGroupRatingsDefinitionInputPanel.this);
              }
            };

            if (item.getIndex() == (getList().size() - 1))
            {
              moveRightLink.setVisible(false);
            }

            item.add(moveRightLink);
          }
        });

    // The "addGroupRatingDefinitionLink" link
    add(new AjaxLink("addGroupRatingDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            System.out.println("[DEBUG] add survey group rating definition link clicked");

          }
        });

    // The "groupMemberDefinition" list view
    add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition", new PropertyModel<>(
        groupDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            item.add(new Label("name", new PropertyModel(item.getModel(), "name")));

            // The "moveUpLink" link
            AjaxLink moveUpLink = new AjaxLink("moveUpLink")

            {
              @Override
              public void onClick(AjaxRequestTarget ajaxRequestTarget)
              {
                SurveyDefinition surveyDefinition =
                    (SurveyDefinition) getForm().getDefaultModelObject();

                surveyDefinition.moveGroupMemberDefinitionUp(item.getModelObject());

                ajaxRequestTarget.add(SurveyGroupRatingsDefinitionInputPanel.this);
              }
            };

            if (item.getIndex() == 0)
            {
              moveUpLink.setVisible(false);
            }

            item.add(moveUpLink);

            // The "removeLink" link
            item.add(new AjaxLink("removeLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                getDialog().show(target, new RemoveGroupMemberDialogImplementation(item.getModel()));
              }
            });

            // The "moveDownLink" link
            AjaxLink moveDownLink = new AjaxLink("moveDownLink")

            {
              @Override
              public void onClick(AjaxRequestTarget ajaxRequestTarget)
              {
                SurveyDefinition surveyDefinition =
                    (SurveyDefinition) getForm().getDefaultModelObject();

                surveyDefinition.moveGroupMemberDefinitionDown(item.getModelObject());

                ajaxRequestTarget.add(SurveyGroupRatingsDefinitionInputPanel.this);
              }
            };

            if (item.getIndex() == (getList().size() - 1))
            {
              moveDownLink.setVisible(false);
            }

            item.add(moveDownLink);

            // The "groupRatingType" list view
            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingType",
                new PropertyModel<>(groupRatingsDefinitionModel, "groupRatingDefinitions"))
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
              {
                SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

                item.add(new Label("ratingType", groupRatingDefinition.getRatingType()
                    .description()));
              }
            });
          }
        });

    add(new AjaxLink("addGroupMemberDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            System.out.println("[DEBUG] add survey group member definition link clicked");

          }
        });
  }

  /**
   * The <code>RemoveGroupMemberDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class RemoveGroupMemberDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel;

    /**
     * Constructs a new <code>RemoveGroupMemberDialogImplementation</code>.
     *
     * @param groupMemberDefinitionModel the model for the survey group member definition being
     *                                   removed
     */
    public RemoveGroupMemberDialogImplementation(
        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
    {
      super("Remove Survey Group Member", "Yes", "No");

      this.groupMemberDefinitionModel = groupMemberDefinitionModel;

      add(new Label("name", new PropertyModel<String>(groupMemberDefinitionModel, "name")));
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyDefinition surveyDefinition = (SurveyDefinition) SurveyGroupRatingsDefinitionInputPanel
          .this.getForm().getModelObject();

      surveyDefinition.removeGroupMemberDefinition(groupMemberDefinitionModel.getObject().getId());

      target.add(SurveyGroupRatingsDefinitionInputPanel.this);

      return true;
    }

    @Override
    public void resetModel() {}
  }

  /**
   * The <code>RemoveGroupRatingDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class RemoveGroupRatingDialogImplementation extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel;

    /**
     * Constructs a new <code>RemoveGroupRatingDialogImplementation</code>.
     *
     * @param groupRatingDefinitionModel the model for the survey group rating definition being
     *                                   removed
     */
    public RemoveGroupRatingDialogImplementation(
      IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
    {
      super("Remove Survey Group Rating", "Yes", "No");

      this.groupRatingDefinitionModel = groupRatingDefinitionModel;

      add(new Label("name", new PropertyModel<String>(groupRatingDefinitionModel, "name")));
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      SurveyDefinition surveyDefinition = (SurveyDefinition) SurveyGroupRatingsDefinitionInputPanel
        .this.getForm().getModelObject();

      surveyDefinition.removeGroupRatingDefinition(groupRatingDefinitionModel.getObject().getId());

      target.add(SurveyGroupRatingsDefinitionInputPanel.this);

      return true;
    }

    @Override
    public void resetModel() {}
  }

///**
// * The <code>AddGroupMemberDefinitionDialog</code> class.
// */
//private class AddGroupMemberDefinitionDialog extends FormDialog
//{
//  private static final long serialVersionUID = 1000000;
//  private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;
//  private String name;
//
//  /**
//   * Constructs a new <code>AddGroupMemberDefinitionDialog</code>.
//   */
//  AddGroupMemberDefinitionDialog()
//  {
//    super("addGroupMemberDefinitionDialog", "Add Survey Group Member Definition", "Add",
//        "Cancel");
//
//    try
//    {
//      // The "name" field
//      TextField<String> nameField = new TextField<>("name", new PropertyModel<>(this, "name"));
//      nameField.setRequired(false);
//      nameField.setEnabled(false);
//      nameField.setOutputMarkupId(true);
//      getForm().add(nameField);
//    }
//    catch (Throwable e)
//    {
//      throw new WebApplicationException(
//          "Failed to initialise the AddGroupMemberDefinitionDialog", e);
//    }
//  }
//
//  /**
//   * Show the dialog using Ajax.
//   *
//   * @param target                      the AJAX request target
//   * @param groupRatingsDefinitionModel the model for the survey group ratings definition being
//   *                                    removed
//   */
//  void show(AjaxRequestTarget target,
//      IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel)
//  {
//    this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;
//
//    target.add(this);
//
//    super.show(target);
//  }
//
//  /**
//   * Process the cancellation of the form associated with the dialog.
//   *
//   * @param target the AJAX request target
//   * @param form   the form
//   */
//  @Override
//  protected void onCancel(AjaxRequestTarget target, Form form) {}
//
//  /**
//   * Process the submission of the form associated with the dialog.
//   *
//   * @param target the AJAX request target
//   * @param form   the form
//   */
//  @Override
//  protected void onSubmit(AjaxRequestTarget target, Form form)
//  {
//    resetDialog(target);
//
//    target.add(getAlerts());
//
//    hide(target);
//  }
//
//  /**
//   * Reset the model for the dialog.
//   */
//  @Override
//  protected void resetDialogModel() {}
//}
//
//


}
