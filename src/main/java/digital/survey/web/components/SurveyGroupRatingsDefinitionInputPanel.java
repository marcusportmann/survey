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
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.template.components.Dialog;
import guru.mmp.application.web.template.components.ExtensibleFormDialogImplementation;
import guru.mmp.application.web.template.components.FormDialog;
import org.apache.wicket.MarkupContainer;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

//~--- JDK imports ------------------------------------------------------------

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
                //removeGroupRatingDefinitionDialog.show(target);
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
                getDialog().show(target, new RemoveGroupMemberDialogImplementation());

                //removeGroupMemberDefinitionDialog.show(target);
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

    // The dialog used to add a new survey group rating definition
    //addGroupRatingDefinitionDialog = new AddGroupRatingDefinitionDialog();
    //add(addGroupRatingDefinitionDialog);

    // The dialog used to add a new survey group member definition
    //addGroupMemberDefinitionDialog = new AddGroupMemberDefinitionDialog();
    //add(addGroupMemberDefinitionDialog);

    // The dialog used to confirm the removal of a survey group rating definition
    //removeGroupRatingDefinitionDialog = new RemoveGroupRatingDefinitionDialog();
    //add(removeGroupRatingDefinitionDialog);

    // The dialog used to confirm the removal of a survey group member definition
    //removeGroupMemberDefinitionDialog = new RemoveGroupMemberDefinitionDialog();
    //add(removeGroupMemberDefinitionDialog);
  }

  public class RemoveGroupMemberDialogImplementation extends ExtensibleFormDialogImplementation
  {
    public RemoveGroupMemberDialogImplementation()
    {
      super("Remove Survey Group Member Definition", "Yes", "No");


      add(new Label("name", "TESTING"));
    }

    @Override
    public void resetModel()
    {

    }

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      error(target, "This is a test error message");

      return false;
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form)
    {

    }

    @Override
    public void onError(AjaxRequestTarget target, Form form)
    {

    }
  }



//  /**
//   * The <code>AddGroupMemberDefinitionDialog</code> class.
//   */
//  private class AddGroupMemberDefinitionDialog extends FormDialog
//  {
//    private static final long serialVersionUID = 1000000;
//    private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;
//    private String name;
//
//    /**
//     * Constructs a new <code>AddGroupMemberDefinitionDialog</code>.
//     */
//    AddGroupMemberDefinitionDialog()
//    {
//      super("addGroupMemberDefinitionDialog", "Add Survey Group Member Definition", "Add",
//          "Cancel");
//
//      try
//      {
//        // The "name" field
//        TextField<String> nameField = new TextField<>("name", new PropertyModel<>(this, "name"));
//        nameField.setRequired(false);
//        nameField.setEnabled(false);
//        nameField.setOutputMarkupId(true);
//        getForm().add(nameField);
//      }
//      catch (Throwable e)
//      {
//        throw new WebApplicationException(
//            "Failed to initialise the AddGroupMemberDefinitionDialog", e);
//      }
//    }
//
//    /**
//     * Show the dialog using Ajax.
//     *
//     * @param target                      the AJAX request target
//     * @param groupRatingsDefinitionModel the model for the survey group ratings definition being
//     *                                    removed
//     */
//    void show(AjaxRequestTarget target,
//        IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel)
//    {
//      this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;
//
//      target.add(this);
//
//      super.show(target);
//    }
//
//    /**
//     * Process the cancellation of the form associated with the dialog.
//     *
//     * @param target the AJAX request target
//     * @param form   the form
//     */
//    @Override
//    protected void onCancel(AjaxRequestTarget target, Form form) {}
//
//    /**
//     * Process the submission of the form associated with the dialog.
//     *
//     * @param target the AJAX request target
//     * @param form   the form
//     */
//    @Override
//    protected void onSubmit(AjaxRequestTarget target, Form form)
//    {
//      resetDialog(target);
//
//      target.add(getAlerts());
//
//      hide(target);
//    }
//
//    /**
//     * Reset the model for the dialog.
//     */
//    @Override
//    protected void resetDialogModel() {}
//  }
//
//



//  /**
//   * The <code>RemoveGroupMemberDefinitionDialog</code> class.
//   */
//  private class RemoveGroupMemberDefinitionDialog extends Dialog
//  {
//    private static final long serialVersionUID = 1000000;
//    private IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel;
//    private Label nameLabel;
//
//    /**
//     * Constructs a new <code>RemoveGroupMemberDefinitionDialog</code>.
//     */
//    RemoveGroupMemberDefinitionDialog()
//    {
//      super("removeGroupMemberDefinitionDialog");
//
//      setOutputMarkupId(true);
//
//      nameLabel = new Label("name", Model.of(""));
//
//      add(nameLabel);
//
//      // The "removeLink" link
//      AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
//      {
//        private static final long serialVersionUID = 1000000;
//
//        @Override
//        public void onClick(AjaxRequestTarget target)
//        {
//          SurveyDefinition surveyDefinition =
//              (SurveyDefinition) getSurveyDefinitionInputPanel().getDefaultModelObject();
//
//          surveyDefinition.removeGroupMemberDefinition(groupMemberDefinitionModel.getObject()
//              .getId());
//
//          target.add(SurveyGroupRatingsDefinitionInputPanel.this);
//
//          hide(target);
//        }
//      };
//      add(removeLink);
//    }
//
//    /**
//     * Show the dialog using Ajax.
//     *
//     * @param target                     the AJAX request target
//     * @param groupMemberDefinitionModel the model for the survey group member definition being
//     *                                   removed
//     */
//    void show(AjaxRequestTarget target,
//        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
//    {
//      this.groupMemberDefinitionModel = groupMemberDefinitionModel;
//
//      nameLabel.setDefaultModel(new PropertyModel<>(groupMemberDefinitionModel, "name"));
//
//      target.add(this);
//
//      super.show(target);
//    }
//  }


//  /**
//   * The <code>RemoveGroupRatingDefinitionDialog</code> class.
//   */
//  private class RemoveGroupRatingDefinitionDialog extends Dialog
//  {
//    private static final long serialVersionUID = 1000000;
//    private IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel;
//    private Label nameLabel;
//    private String itemDefinitionInputPanelId;
//
//    /**
//     * Constructs a new <code>RemoveGroupRatingDefinitionDialog</code>.
//     */
//    RemoveGroupRatingDefinitionDialog()
//    {
//      super("removeGroupRatingDefinitionDialog");
//
//      setOutputMarkupId(true);
//
//      nameLabel = new Label("name", Model.of(""));
//      add(nameLabel);
//
//      // The "removeLink" link
//      AjaxLink<Void> removeLink = new AjaxLink<Void>("removeLink")
//      {
//        private static final long serialVersionUID = 1000000;
//
//        @Override
//        public void onClick(AjaxRequestTarget target)
//        {
//          SurveyDefinition surveyDefinition =
//              (SurveyDefinition) getSurveyDefinitionInputPanel().getDefaultModelObject();
//
//          surveyDefinition.removeGroupRatingDefinition(groupRatingDefinitionModel.getObject()
//              .getId());
//
//          target.add(SurveyGroupRatingsDefinitionInputPanel.this);
//
//          hide(target);
//        }
//      };
//      add(removeLink);
//    }
//
//    /**
//     * Show the dialog using Ajax.
//     *
//     * @param target                     the AJAX request target
//     * @param groupRatingDefinitionModel the model for the survey group rating definition being
//     *                                   removed
//     */
//    void show(AjaxRequestTarget target,
//        IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel,
//        String itemDefinitionInputPanelId)
//    {
//      this.groupRatingDefinitionModel = groupRatingDefinitionModel;
//      this.itemDefinitionInputPanelId = itemDefinitionInputPanelId;
//
//      nameLabel.setDefaultModel(new PropertyModel<>(groupRatingDefinitionModel, "name"));
//
//      target.add(this);
//
//      super.show(target);
//    }
//  }
}
