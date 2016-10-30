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
import guru.mmp.application.web.data.InjectableDataProvider;
import guru.mmp.common.util.StringUtil;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>FilteredLatestSurveyDefinitionSummaryDataProvider</code> class provides an
 * <code>IDataProvider</code> implementation that retrieves <code>SurveyDefinitionSummary</code>
 * instances from the database.
 *
 * This data provider retrieves the summaries for the latest versions of the survey definitions.
 *
 * @author Marcus Portmann
 */
public class FilteredSurveyDefinitionSummaryDataProvider
    extends InjectableDataProvider<SurveyDefinitionSummary>
{
  private static final long serialVersionUID = 1000000;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey
   * definitions are associated with.
   */
  private UUID organisationId;

  /**
   * The filter used to limit the matching survey definitions.
   */
  private String filter = "";

  /**
   * Constructs a new <code>FilteredLatestSurveyDefinitionSummaryDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected FilteredSurveyDefinitionSummaryDataProvider() {}

  /**
   * Constructs a new <code>FilteredLatestSurveyDefinitionSummaryDataProvider</code>.
   *
   * @param organisationId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       organisation the survey definitions are associated with
   */
  public FilteredSurveyDefinitionSummaryDataProvider(UUID organisationId)
  {
    this.organisationId = organisationId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Returns the filter used to limit the matching survey definitions.
   *
   * @return the filter used to limit the matching survey definitions
   */
  public String getFilter()
  {
    return filter;
  }

  /**
   * Retrieves the matching survey definitions from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey definitions retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyDefinitionSummary> iterator(long first, long count)
  {
    try
    {
      List<SurveyDefinitionSummary> allSurveyDefinitionSummarys = StringUtil.isNullOrEmpty(filter)
          ? surveyService.getSurveyDefinitionSummariesForOrganisation(organisationId)
          : surveyService.getFilteredSurveyDefinitionSummariesForOrganisation(organisationId,
              filter);

      return allSurveyDefinitionSummarys.subList((int) first, (int) Math.min(first + count,
          allSurveyDefinitionSummarys.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the summaries for the survey definitions for the organisation (%s) from"
          + " index (%d) to (%d)", organisationId, first, first + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyDefinitionSummary</code> POJO with a Wicket model.
   *
   * @param surveyDefinition the <code>SurveyDefinitionSummary</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyDefinitionSummary</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyDefinitionSummary> model(SurveyDefinitionSummary surveyDefinition)
  {
    return new DetachableSurveyDefinitionSummaryModel(surveyDefinition);
  }

  /**
   * Set the filter used to limit the matching survey definitions.
   *
   * @param filter the filter used to limit the matching survey definitions
   */
  public void setFilter(String filter)
  {
    this.filter = filter;
  }

  /**
   * Returns the total number of survey definitions.
   *
   * @return the total number of survey definitions
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return StringUtil.isNullOrEmpty(filter)
          ? surveyService.getNumberOfSurveyDefinitionsForOrganisation(organisationId)
          : surveyService.getNumberOfFilteredSurveyDefinitionsForOrganisation(organisationId,
              filter);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format("Failed to retrieve the number of survey"
          + " definitions for the organisation (%s)", organisationId), e);
    }
  }
}
