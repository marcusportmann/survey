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
import guru.mmp.application.web.template.components.DropDownChoiceWithFeedback;
import guru.mmp.application.web.template.components.ExtensibleFormDialogImplementation;
import guru.mmp.application.web.template.components.TextFieldWithFeedback;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.form.DropDownChoice;
import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.TextField;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

import java.util.ArrayList;
import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsDefinitionPanel</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyGroupRatingsDefinitionPanel extends SurveyItemDefinitionPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinitionPanel</code>.
   *
   * @param id                                the non-null id of this component
   * @param surveyItemDefinitionsModel        the model for the list of survey item definitions the
   *                                          survey group ratings definition is associated with
   * @param surveyGroupRatingsDefinitionModel the model for the survey group ratings definition
   */
  public SurveyGroupRatingsDefinitionPanel(String id,
      IModel<List<SurveyItemDefinition>> surveyItemDefinitionsModel,
      IModel<SurveyGroupRatingsDefinition> surveyGroupRatingsDefinitionModel)
  {
    super(id, surveyItemDefinitionsModel, surveyGroupRatingsDefinitionModel);

    getBodyContainer().add(new ListView<SurveyGroupRatingDefinition>("groupRatingDefinition",
        new PropertyModel<>(surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
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
                surveyGroupRatingsDefinitionModel.getObject().moveGroupRatingDefinitionUp(
                    item.getModelObject());

                target.add(getBodyContainer());
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
                getDialog().show(target, new RemoveGroupRatingDefinitionDialogImplementation(
                    surveyGroupRatingsDefinitionModel, item.getModel()));
              }
            });

            // The "moveRightLink" link
            AjaxLink moveRightLink = new AjaxLink("moveRightLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                surveyGroupRatingsDefinitionModel.getObject().moveGroupRatingDefinitionDown(
                    item.getModelObject());

                target.add(getBodyContainer());
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
    getBodyContainer().add(new AjaxLink("addGroupRatingDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            getDialog().show(target, new AddGroupRatingDefinitionDialogImplementation(
                surveyGroupRatingsDefinitionModel));
          }
        });

    // The "groupMemberDefinition" list view
    getBodyContainer().add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition",
        new PropertyModel<>(surveyGroupRatingsDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            item.add(new Label("name", new PropertyModel(item.getModel(), "name")));

            // The "moveUpLink" link
            AjaxLink moveUpLink = new AjaxLink("moveUpLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                surveyGroupRatingsDefinitionModel.getObject().moveGroupMemberDefinitionUp(
                    item.getModelObject());

                target.add(getBodyContainer());
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
                getDialog().show(target, new RemoveGroupMemberDefinitionDialogImplementation(
                    surveyGroupRatingsDefinitionModel, item.getModel()));
              }
            });

            // The "moveDownLink" link
            AjaxLink moveDownLink = new AjaxLink("moveDownLink")

            {
              @Override
              public void onClick(AjaxRequestTarget target)
              {
                surveyGroupRatingsDefinitionModel.getObject().moveGroupMemberDefinitionDown(
                    item.getModelObject());

                target.add(getBodyContainer());
              }
            };

            if (item.getIndex() == (getList().size() - 1))
            {
              moveDownLink.setVisible(false);
            }

            item.add(moveDownLink);

            // The "groupRatingType" list view
            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingType",
                new PropertyModel<>(surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
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

    getBodyContainer().add(new AjaxLink("addGroupMemberDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget target)
          {
            getDialog().show(target, new AddGroupMemberDefinitionDialogImplementation(
                surveyGroupRatingsDefinitionModel));
          }
        });
  }

  /**
   * Returns the Font Awesome CSS class for the icon for the survey item definition.
   *
   * @return the Font Awesome CSS class for the icon for the survey item definition
   */
  @Override
  protected String getIconClass()
  {
    return "fa-table";
  }

  /**
   * Returns whether the survey item definition is collapsible.
   *
   * @return <code>true</code> if the survey item definition is collapsible or <code>false</code>
   *         otherwise
   */
  @Override
  protected boolean isCollapsible()
  {
    return false;
  }

  /**
   * The <code>AddGroupMemberDefinitionDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class AddGroupMemberDefinitionDialogImplementation
      extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;
    private String name;

    /**
     * Constructs a new <code>AddGroupMemberDefinitionDialogImplementation</code>.
     *
     * @param groupRatingsDefinitionModel the model for the survey group ratings definition the
     *                                    survey group member definition is being added to
     */
    public AddGroupMemberDefinitionDialogImplementation(
        IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel)
    {
      super("Add Survey Group Member Definition", "OK", "Canel");

      this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;

      // The "name" field
      TextField nameField = new TextFieldWithFeedback<>("name", new PropertyModel<>(this, "name"));
      nameField.setRequired(true);
      getForm().add(nameField);
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      groupRatingsDefinitionModel.getObject().addGroupMemberDefinition(
          new SurveyGroupMemberDefinition(name));

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}
  }


  /**
   * The <code>AddGroupRatingDefinitionDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class AddGroupRatingDefinitionDialogImplementation
      extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;
    private String name;
    private SurveyGroupRatingType groupRatingType;

    /**
     * Constructs a new <code>AddGroupRatingDefinitionDialogImplementation</code>.
     *
     * @param groupRatingsDefinitionModel the model for the survey group ratings definition the
     *                                    survey group rating definition is being added to
     */
    public AddGroupRatingDefinitionDialogImplementation(
        IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel)
    {
      super("Add Survey Group Rating Definition", "OK", "Cancel");

      this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;

      // The "name" field
      TextField nameField = new TextFieldWithFeedback<>("name", new PropertyModel<>(this, "name"));
      nameField.setRequired(true);
      getForm().add(nameField);

      SurveyGroupRatingTypeChoiceRenderer surveyGroupRatingTypeChoiceRenderer =
          new SurveyGroupRatingTypeChoiceRenderer();

      // The "groupRatingType" field
      DropDownChoice<SurveyGroupRatingType> groupRatingTypeField = new DropDownChoiceWithFeedback<>(
          "groupRatingType", new PropertyModel<>(this, "groupRatingType"), getRatingTypeOptions(),
          surveyGroupRatingTypeChoiceRenderer);
      groupRatingTypeField.setRequired(true);
      getForm().add(groupRatingTypeField);
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      groupRatingsDefinitionModel.getObject().addGroupRatingDefinition(
          new SurveyGroupRatingDefinition(name, groupRatingType));

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}

    private List<SurveyGroupRatingType> getRatingTypeOptions()
    {
      List<SurveyGroupRatingType> ratingTypes = new ArrayList<>();

      ratingTypes.add(SurveyGroupRatingType.YES_NO_NA);
      ratingTypes.add(SurveyGroupRatingType.ONE_TO_TEN);

      return ratingTypes;
    }
  }


  /**
   * The <code>RemoveGroupMemberDefinitionDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class RemoveGroupMemberDefinitionDialogImplementation
      extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel;
    private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;

    /**
     * Constructs a new <code>RemoveGroupMemberDefinitionDialogImplementation</code>.
     *
     * @param groupRatingsDefinitionModel the model for the survey group ratings definition
     * @param groupMemberDefinitionModel  the model for the survey group member definition being
     *                                    removed
     */
    public RemoveGroupMemberDefinitionDialogImplementation(
        IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel,
        IModel<SurveyGroupMemberDefinition> groupMemberDefinitionModel)
    {
      super("Remove Survey Group Member Definition", "Yes", "No");

      this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;
      this.groupMemberDefinitionModel = groupMemberDefinitionModel;

      /*
       * NOTE: We need to retrieve the name of the member definition here explicitly and not use
       *       a PropertyModel on the groupMemberDefinitionModel object with the "name" field
       *       because after removing the group member definition the model will no longer be
       *       valid and we will get an IndexOutOfBoundsException exception. This is as a result of
       *       the groupMemberDefinitionModel being a ListItemModel, which references an item in
       *       a list view that has been removed.
       */
      getForm().add(new Label("name", new Model<>(groupMemberDefinitionModel.getObject()
          .getName())));
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      groupRatingsDefinitionModel.getObject().removeGroupMemberDefinition(
          groupMemberDefinitionModel.getObject());

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}
  }


  /**
   * The <code>RemoveGroupRatingDefinitionDialogImplementation</code> class.
   *
   * @author Marcus Portmann
   */
  public class RemoveGroupRatingDefinitionDialogImplementation
      extends ExtensibleFormDialogImplementation
  {
    private IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel;
    private IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel;

    /**
     * Constructs a new <code>RemoveGroupRatingDefinitionDialogImplementation</code>.
     *
     * @param groupRatingsDefinitionModel the model for the survey group ratings definition
     * @param groupRatingDefinitionModel  the model for the survey group rating definition being
     *                                    removed
     */
    public RemoveGroupRatingDefinitionDialogImplementation(
        IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel,
        IModel<SurveyGroupRatingDefinition> groupRatingDefinitionModel)
    {
      super("Remove Survey Group Rating Definition", "Yes", "No");

      this.groupRatingsDefinitionModel = groupRatingsDefinitionModel;
      this.groupRatingDefinitionModel = groupRatingDefinitionModel;

      /*
       * NOTE: We need to retrieve the name of the rating definition here explicitly and not use
       *       a PropertyModel on the groupRatingDefinitionModel object with the "name" field
       *       because after removing the group rating definition the model will no longer be
       *       valid and we will get an IndexOutOfBoundsException exception. This is as a result of
       *       the groupRatingDefinitionModel being a ListItemModel, which references an item in
       *       a list view that has been removed.
       */
      getForm().add(new Label("name", new Model<>(groupRatingDefinitionModel.getObject()
          .getName())));
    }

    @Override
    public void onCancel(AjaxRequestTarget target, Form form) {}

    @Override
    public void onError(AjaxRequestTarget target, Form form) {}

    @Override
    public boolean onSubmit(AjaxRequestTarget target, Form form)
    {
      groupRatingsDefinitionModel.getObject().removeGroupRatingDefinition(
          groupRatingDefinitionModel.getObject());

      target.add(getBodyContainer());

      return true;
    }

    @Override
    public void resetModel() {}
  }
}
