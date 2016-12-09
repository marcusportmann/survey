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

import digital.survey.model.SurveyGroupDefinition;
import digital.survey.model.SurveyGroupMemberDefinition;
import digital.survey.model.SurveyGroupRatingDefinition;
import digital.survey.model.SurveyGroupRatingsDefinition;
import guru.mmp.application.web.template.components.InputPanel;
import org.apache.wicket.MarkupContainer;
import org.apache.wicket.ajax.AjaxRequestTarget;
import org.apache.wicket.ajax.markup.html.AjaxLink;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsDefinitionInputPanel</code> class.
 *
 * @author Marcus Portmann
 */
class SurveyGroupRatingsDefinitionInputPanel extends InputPanel
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinitionInputPanel</code>.
   *
   * @param id                          the non-null id of this component
   * @param groupRatingsDefinitionModel the model for the survey group ratings definition
   * @param groupDefinitionModel        the model for the survey group definition
   */
  SurveyGroupRatingsDefinitionInputPanel(String id,
      IModel<SurveyGroupRatingsDefinition> groupRatingsDefinitionModel,
      IModel<SurveyGroupDefinition> groupDefinitionModel)
  {
    super(id);

    add(new ListView<SurveyGroupRatingDefinition>("groupRatingDefinition", new PropertyModel<>(
        groupRatingsDefinitionModel, "groupRatingDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            List<SurveyGroupRatingDefinition> groupRatingDefinitions = getList();

            SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

            int index = groupRatingDefinitions.indexOf(groupRatingDefinition);

            item.add(new Label("name", new PropertyModel(groupRatingDefinition, "name")));

            ShiftGroupRatingDefinitionLeftLink shiftLeftLink =
                new ShiftGroupRatingDefinitionLeftLink("shiftLeftLink", groupRatingDefinition);

            if (index == 0)
            {
              shiftLeftLink.setVisible(false);
            }

            item.add(shiftLeftLink);

            item.add(new RemoveGroupRatingDefinitionLink("removeLink", groupRatingDefinition));

            ShiftGroupRatingDefinitionRightLink shiftRightLink =
                new ShiftGroupRatingDefinitionRightLink("shiftRightLink", groupRatingDefinition);

            if (index == (groupRatingDefinitions.size() - 1))
            {
              shiftRightLink.setVisible(false);
            }

            item.add(shiftRightLink);
          }
        });

    add(new AjaxLink("addGroupRatingDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget ajaxRequestTarget)
          {
            System.out.println("[DEBUG] add survey group rating definition link clicked");

          }
        });

    add(new ListView<SurveyGroupMemberDefinition>("groupMemberDefinition", new PropertyModel<>(
        groupDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            SurveyGroupMemberDefinition groupMemberDefinition = item.getModelObject();

            List<SurveyGroupMemberDefinition> groupMemberDefinitions = getList();

            int index = groupMemberDefinitions.indexOf(groupMemberDefinition);

            item.add(new Label("name", new PropertyModel(groupMemberDefinition, "name")));

            ShiftGroupMemberDefinitionUpLink shiftUpLink = new ShiftGroupMemberDefinitionUpLink(
                "shiftUpLink", groupMemberDefinition);

            if (index == 0)
            {
              shiftUpLink.setVisible(false);
            }

            item.add(shiftUpLink);

            item.add(new RemoveGroupMemberDefinitionLink("removeLink", groupMemberDefinition));

            ShiftGroupMemberDefinitionDownLink shiftDownLink =
                new ShiftGroupMemberDefinitionDownLink("shiftDownLink", groupMemberDefinition);

            if (index == (groupMemberDefinitions.size() - 1))
            {
              shiftDownLink.setVisible(false);
            }

            item.add(shiftDownLink);
          }
        });

    add(new AjaxLink("addGroupMemberDefinitionLink")
        {
          @Override
          public void onClick(AjaxRequestTarget ajaxRequestTarget)
          {
            System.out.println("[DEBUG] add survey group member definition link clicked");

          }
        });
  }

  private SurveyDefinitionInputPanel getSurveyDefinitionInputPanel()
  {
    MarkupContainer parent = getParent();

    while (parent != null)
    {
      if (parent instanceof SurveyDefinitionInputPanel)
      {
        return (SurveyDefinitionInputPanel) parent;
      }

      parent = parent.getParent();
    }

    return null;
  }

  class RemoveGroupMemberDefinitionLink extends AjaxLink
  {
    private SurveyGroupMemberDefinition groupMemberDefinition;

    /**
     * Constructs a new <code>RemoveGroupMemberDefinitionLink</code>.
     *
     * @param id                    the non-null id of this component
     * @param groupMemberDefinition the survey group member definition this link is associated with
     */
    RemoveGroupMemberDefinitionLink(String id, SurveyGroupMemberDefinition groupMemberDefinition)
    {
      super(id);

      this.groupMemberDefinition = groupMemberDefinition;
    }

    @Override
    public void onClick(AjaxRequestTarget ajaxRequestTarget)
    {
      getSurveyDefinitionInputPanel().showRemoveGroupMemberDefinitionDialog(ajaxRequestTarget,
          groupMemberDefinition);
    }
  }


  /**
   * The <code>RemoveGroupRatingDefinitionLink</code> class.
   */
  class RemoveGroupRatingDefinitionLink extends AjaxLink
  {
    private SurveyGroupRatingDefinition groupRatingDefinition;

    /**
     * Constructs a new <code>RemoveGroupRatingDefinitionLink</code>.
     *
     * @param id                    the non-null id of this component
     * @param groupRatingDefinition the survey group rating definition this link is associated with
     */
    RemoveGroupRatingDefinitionLink(String id, SurveyGroupRatingDefinition groupRatingDefinition)
    {
      super(id);

      this.groupRatingDefinition = groupRatingDefinition;
    }

    @Override
    public void onClick(AjaxRequestTarget ajaxRequestTarget)
    {
      getSurveyDefinitionInputPanel().showRemoveGroupRatingDefinitionDialog(ajaxRequestTarget,
          groupRatingDefinition);
    }
  }


  /**
   * The <code>ShiftGroupMemberDefinitionDownLink</code> class.
   */
  class ShiftGroupMemberDefinitionDownLink extends AjaxLink
  {
    private SurveyGroupMemberDefinition groupMemberDefinition;

    /**
     * Constructs a new <code>ShiftGroupMemberDefinitionDownLink</code>.
     *
     * @param id                    the non-null id of this component
     * @param groupMemberDefinition the survey group member definition this link is associated with
     */
    ShiftGroupMemberDefinitionDownLink(String id, SurveyGroupMemberDefinition groupMemberDefinition)
    {
      super(id);

      this.groupMemberDefinition = groupMemberDefinition;
    }

    @Override
    public void onClick(AjaxRequestTarget ajaxRequestTarget)
    {
//    SurveyDefinition surveyDefinition =
//        (SurveyDefinition) getSurveyDefinitionInputPanel().getDefaultModelObject();

      // for (SurveyGroupDefinition )

      System.out.println("[DEBUG] shift down link clicked for the survey group member definition: "
          + groupMemberDefinition.getName());
    }
  }


  /**
   * The <code>ShiftGroupMemberDefinitionUpLink</code> class.
   */
  class ShiftGroupMemberDefinitionUpLink extends AjaxLink
  {
    private SurveyGroupMemberDefinition groupMemberDefinition;

    /**
     * Constructs a new <code>ShiftGroupMemberDefinitionUpLink</code>.
     *
     * @param id                    the non-null id of this component
     * @param groupMemberDefinition the survey group member definition this link is associated with
     */
    ShiftGroupMemberDefinitionUpLink(String id, SurveyGroupMemberDefinition groupMemberDefinition)
    {
      super(id);

      this.groupMemberDefinition = groupMemberDefinition;
    }

    @Override
    public void onClick(AjaxRequestTarget ajaxRequestTarget)
    {
      System.out.println("[DEBUG] shift up link clicked for the survey group member definition: "
          + groupMemberDefinition.getName());
    }
  }


  /**
   * The <code>ShiftGroupRatingDefinitionLeftLink</code> class.
   */
  class ShiftGroupRatingDefinitionLeftLink extends AjaxLink
  {
    private SurveyGroupRatingDefinition groupRatingDefinition;

    /**
     * Constructs a new <code>ShiftGroupRatingDefinitionLeftLink</code>.
     *
     * @param id                    the non-null id of this component
     * @param groupRatingDefinition the survey group rating definition this link is associated with
     */
    ShiftGroupRatingDefinitionLeftLink(String id, SurveyGroupRatingDefinition groupRatingDefinition)
    {
      super(id);

      this.groupRatingDefinition = groupRatingDefinition;
    }

    @Override
    public void onClick(AjaxRequestTarget ajaxRequestTarget)
    {
      System.out.println("[DEBUG] shift left link clicked for the survey group rating definition: "
          + groupRatingDefinition.getName());
    }
  }


  /**
   * The <code>ShiftGroupRatingDefinitionRightLink</code> class.
   */
  class ShiftGroupRatingDefinitionRightLink extends AjaxLink
  {
    private SurveyGroupRatingDefinition groupRatingDefinition;

    /**
     * Constructs a new <code>ShiftGroupRatingDefinitionRightLink</code>.
     *
     * @param id                    the non-null id of this component
     * @param groupRatingDefinition the survey group rating definition this link is associated with
     */
    ShiftGroupRatingDefinitionRightLink(String id,
        SurveyGroupRatingDefinition groupRatingDefinition)
    {
      super(id);

      this.groupRatingDefinition = groupRatingDefinition;
    }

    @Override
    public void onClick(AjaxRequestTarget ajaxRequestTarget)
    {
      System.out.println(
          "[DEBUG] shift right link clicked for the survey group rating definition: "
          + groupRatingDefinition.getName());
    }
  }
}
