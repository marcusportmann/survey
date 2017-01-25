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
import org.apache.wicket.behavior.AttributeAppender;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.markup.html.panel.Panel;
import org.apache.wicket.model.IModel;
import org.apache.wicket.model.PropertyModel;

import java.util.List;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsResultPanel</code> class.
 *
 * @author Marcus Portmann
 */
class SurveyGroupRatingsResultPanel extends Panel
{
  /**
   * Constructs a new <code>SurveyGroupRatingsResultPanel</code>.
   *
   * @param id                                the non-null id of this component
   * @param surveyGroupRatingsDefinitionModel the model for the survey group ratings definition
   * @param surveyResultModel                 the model for the survey result
   */
  SurveyGroupRatingsResultPanel(String id,
      IModel<SurveyGroupRatingsDefinition> surveyGroupRatingsDefinitionModel,
      IModel<SurveyResult> surveyResultModel)
  {
    super(id);

    setRenderBodyOnly(true);

    add(new Label("label", new PropertyModel<>(surveyGroupRatingsDefinitionModel, "label")));

    add(new ListView<SurveyGroupRatingDefinition>("groupRating", new PropertyModel<>(
        surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
          {
            SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

            item.add(new Label("name", new PropertyModel<>(groupRatingDefinition, "name")));
          }
        });

    add(new ListView<SurveyGroupMemberDefinition>("groupMember", new PropertyModel<>(
        surveyGroupRatingsDefinitionModel, "groupMemberDefinitions"))
        {
          @Override
          protected void populateItem(ListItem<SurveyGroupMemberDefinition> item)
          {
            SurveyGroupMemberDefinition groupMemberDefinition = item.getModelObject();

            SurveyGroupRatingsDefinition groupRatingsDefinition =
                surveyGroupRatingsDefinitionModel.getObject();

            SurveyResult surveyResult = surveyResultModel.getObject();

            item.add(new Label("name", new PropertyModel<>(groupMemberDefinition, "name")));

            item.add(new ListView<SurveyGroupRatingDefinition>("groupRatingResult",
                new PropertyModel<>(surveyGroupRatingsDefinitionModel, "groupRatingDefinitions"))
            {
              @Override
              protected void populateItem(ListItem<SurveyGroupRatingDefinition> item)
              {
                SurveyGroupRatingDefinition groupRatingDefinition = item.getModelObject();

                if (groupRatingDefinition.getRatingType() == SurveyGroupRatingType.YES_NO_NA)
                {
                  SurveyGroupRatingResult groupRatingResult = surveyResult.getGroupRatingResult(
                      groupRatingsDefinition.getId(), groupRatingDefinition.getId(),
                      groupMemberDefinition.getId());

                  float averageRating = groupRatingResult.getAverageRating();

                  if (averageRating == -1)
                  {
                    Label ratingLabel = new Label("rating", "-");

                    item.add(ratingLabel);
                  }
                  else
                  {
                    int maxNumberOfRatings = groupRatingResult.getRatings().size();

                    int grad = ((int) (averageRating / 5)) * 5;

                    Label ratingLabel = new Label("rating", String.format(
                        "%3.0f%%<br><span class=\"num-ratings\">%d/%d</span>", averageRating,
                        groupRatingResult.getNumberOfRatingsWithValidScore(), maxNumberOfRatings));
                    ratingLabel.setEscapeModelStrings(false);

                    if (groupRatingsDefinition.getDisplayRatingsUsingGradient())
                    {
                      ratingLabel.add(new AttributeAppender("class", "grad-" + grad));
                    }

                    item.add(ratingLabel);
                  }
                }
                else
                {
                  throw new RuntimeException("Unsupported survey group rating item type ("
                      + groupRatingDefinition.getRatingType() + ")");
                }

              }
            });

            // Calculate and show the total
            List<SurveyGroupRatingResult> groupRatingResults =
                surveyResult.getGroupRatingResultsForGroupMember(groupMemberDefinition.getId());

            float totalAverageRating = 0;
            int totalNumberOfRatingsWithValidScore = 0;

            for (SurveyGroupRatingResult groupRatingResult : groupRatingResults)
            {
              float averageRating = groupRatingResult.getAverageRating();

              totalAverageRating += (averageRating
                  * groupRatingResult.getNumberOfRatingsWithValidScore());

              totalNumberOfRatingsWithValidScore +=
                  groupRatingResult.getNumberOfRatingsWithValidScore();
            }

            float weightedTotalAverageRating = 0;

            if (totalNumberOfRatingsWithValidScore > 0)
            {
              weightedTotalAverageRating = totalAverageRating / totalNumberOfRatingsWithValidScore;
            }

            int grad = ((int) (weightedTotalAverageRating / 5)) * 5;

            Label ratingLabel = new Label("total", String.format("%3.0f%%",
                weightedTotalAverageRating));

            ratingLabel.setEscapeModelStrings(false);

            if (groupRatingsDefinition.getDisplayRatingsUsingGradient())
            {
              ratingLabel.add(new AttributeAppender("class", "grad-" + grad));
            }

            item.add(ratingLabel);

          }
        });
  }

  @SuppressWarnings("unused")
  private String getColor(float min, float max, float value)
  {
    float green_max = 220;
    float red_max = 220;
    float red;
    float green;
    float blue = 0;

    if (value < max / 2)
    {
      red = red_max;
      green = Math.round((value / ((max - min) / 2)) * green_max);
    }
    else
    {
      green = green_max;
      red = Math.round((1 - ((value - ((max - min) / 2)) / ((max - min) / 2))) * red_max);
    }

    return String.format("color: rgb(%d, %d, %d);", (int) red, (int) green, (int) blue);
  }
}



// TODO
//
//            REMEMBER TO CALCULATE WEIGHTED TOTAL
//
//
//            ADD AN ATTRIBUTE TO THE SURVEY GROUP DEFINITION TO INDICATE WHETHER TO USE GRADIENTS FOR RATINGS useGradientForGroupRatingResults
//
//            REMEMBER TO CHECK TOTAL AND GRADIENT FLAGS
//
//
//            REGENERATE SURVEY DEFINITIONS
