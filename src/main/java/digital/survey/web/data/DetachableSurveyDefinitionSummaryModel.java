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

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyDefinitionSummary;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableLoadableDetachableModel;

import javax.inject.Inject;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>DetachableSurveyDefinitionSummaryModel</code> class provides a detachable model
 * implementation for the <code>SurveyDefinitionSummary</code> model class.
 *
 * This detachable model implementation retrieves the summary for a version of a particular survey
 * definition.
 *
 * @author Marcus Portmann
 */
public class DetachableSurveyDefinitionSummaryModel
    extends InjectableLoadableDetachableModel<SurveyDefinitionSummary>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to, along with the version of the survey
   * definition, uniquely identify the survey definition.
   */
  private UUID id;

  /**
   * The version of the survey definition.
   */
  private int version;

  /**
   * Constructs a new <code>DetachableSurveyDefinitionSummaryModel</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected DetachableSurveyDefinitionSummaryModel() {}

  /**
   * Constructs a new <code>DetachableSurveyDefinitionSummaryModel</code>.
   *
   * @param surveyDefinition the <code>SurveyDefinitionSummary</code> instance
   */
  public DetachableSurveyDefinitionSummaryModel(SurveyDefinitionSummary surveyDefinition)
  {
    this(surveyDefinition.getId(), surveyDefinition.getVersion());

    setObject(surveyDefinition);
  }

  /**
   * Constructs a new <code>DetachableSurveyDefinitionSummaryModel</code>.
   *
   * @param id      the Universally Unique Identifier (UUID) used to, along with the version of the
   *                survey definition, uniquely identify the survey definition
   * @param version the version of the survey definition
   */
  public DetachableSurveyDefinitionSummaryModel(UUID id, int version)
  {
    this.id = id;
    this.version = version;
  }

  /**
   * @see org.apache.wicket.model.LoadableDetachableModel#load()
   */
  @Override
  protected SurveyDefinitionSummary load()
  {
    try
    {
      return surveyService.getSurveyDefinitionSummary(id, version);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the summary for the version (%d) of the survey definition (%s)", version,
          id), e);
    }
  }

  /**
   * Invoked when the model is detached after use.
   */
  @Override
  protected void onDetach()
  {
    super.onDetach();

    setObject(null);
  }
}
